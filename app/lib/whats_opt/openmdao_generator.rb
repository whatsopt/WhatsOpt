# frozen_string_literal: true

require "whats_opt/code_generator"
require "whats_opt/server_generator"

module WhatsOpt
  class OpenmdaoGenerator < CodeGenerator

    class DisciplineNotFoundException < StandardError
    end

    def initialize(mda, pkg_format: false, server_host: nil, driver_name: nil, driver_options: {}, outdir: ".",
                   whatsopt_url: "", api_key: "", remote_ip: "")
      super(mda, pkg_format: pkg_format)
      @prefix = "openmdao"
      @framework = "openmdao"
      @server_host = server_host
      @remote = !server_host.nil?
      @outdir = outdir

      @sgen = WhatsOpt::ServerGenerator.new(mda, pkg_format: pkg_format, server_host: server_host, remote_ip: remote_ip)
      @eggen = WhatsOpt::EgmdoGenerator.new(mda, pkg_format: pkg_format, remote_operation: @remote, outdir: outdir,
                                            driver_name: driver_name, driver_options: driver_options)
      @sqlite_filename = "cases.sqlite"
      @driver_name = driver_name.to_sym if driver_name
      @driver_options = driver_options

      @impl = @mda.openmdao_impl || OpenmdaoAnalysisImpl.new(analysis: @mda)
      @whatsopt_url = whatsopt_url
      @api_key = api_key
      @remote_ip = remote_ip
      @check_only = false
    end

    def to_run_method(category)
      case category.to_s
      when Operation::CAT_RUNONCE 
        "mda"
      when Operation::CAT_DOE
        "doe"
      when Operation::CAT_EGDOE
        "egdoe"
      when Operation::CAT_OPTIMIZATION
        "mdo" 
      when Operation::CAT_EGMDO
        "egmdo" 
      else 
        Rails.logger.error "Operation category #{category} has no run method equivalent"
        "Unknown_operation_for_category_#{category}"
      end
    end

    def check_mda_setup
      ok, lines = false, []
      @mda.set_as_root_module
      Dir.mktmpdir("check_#{@mda.basename}_") do |dir|
        # dir="/tmp/check" # for debug
        begin
          @check_only = true
          _generate_code(dir, with_server: false, with_runops: false)
        rescue ServerGenerator::ThriftError => e
          ok = false
          lines = e.to_s.lines.map(&:chomp)
        else
          ok, log = _check_mda dir
          lines = log.lines.map(&:chomp)
        end
      end
      @mda.unset_root_module
      return ok, lines
    end

    def run(category = Operation::CAT_RUNONCE, sqlite_filename = nil)
      ok, lines = false, []
      Dir.mktmpdir("run_#{@mda.basename}_#{category}") do |dir|
        # dir='/tmp' # for debug
        begin
          _generate_code(dir, sqlite_filename: sqlite_filename)
        rescue ServerGenerator::ThriftError => e
          ok = false
          lines = e.to_s.lines.map(&:chomp)
        else
          method = self.to_run_method(category)
          ok, log = _run_mda(dir, method)
          lines = log.lines.map(&:chomp)
        end
      end
      return ok, lines
    end

    def monitor(category = Operation::CAT_RUNONCE, sqlite_filename = nil, outdir = ".", &block)
      Dir.mktmpdir("run_#{@mda.basename}_#{category}") do |dir|
        # dir="/tmp" # for debug
        _generate_code dir, sqlite_filename: sqlite_filename, outdir: outdir
        method = self.to_run_method(category)
        _monitor_mda(dir, method, &block)
      end
    end

    def _check_mda(dir)
      script = File.join(dir, @mda.py_filename)
      Rails.logger.info "#{PYTHON} #{script} --no-n2"
      stdouterr, status = Open3.capture2e(PYTHON, script, "--no-n2")
      return status.success?, stdouterr
    end

    def _run_mda(dir, method)
      script = File.join(dir, "run_#{method}.py")
      Rails.logger.info "#{PYTHON} #{script}"
      stdouterr, status = Open3.capture2e(PYTHON, script)
      return status.success?, stdouterr
    end

    def _monitor_mda(dir, method, &block)
      script = File.join(dir, "run_#{method}.py")
      Rails.logger.info "#{PYTHON} #{script}"
      Open3.popen2e(PYTHON, script, &block)
    end

    def _generate_code(gendir, options = {})
      # gendir='/tmp' # for debug
      opts = { with_server: true, with_egmdo: false, with_run: true, with_unittests: false }.merge(options)
      pkg_dir = package_dir? ? File.join(gendir, @mda.py_modulename) : gendir
      Dir.mkdir(pkg_dir) unless Dir.exist?(pkg_dir)

      @mda.disciplines.nodes.each do |disc|
        if disc.has_sub_analysis?
          _generate_sub_analysis(disc, pkg_dir, opts)
        else
          _generate_discipline(disc, pkg_dir, opts)
          _generate_test_scripts(disc, pkg_dir) if opts[:with_unittests]
        end
      end
      _generate_main(pkg_dir, opts)
      _generate_run_scripts(gendir, opts)
      if opts[:with_server] || (!@check_only && @mda.has_remote_discipline?(@remote_ip))
        @sgen._generate_code(gendir, @server_host)
        @genfiles += @sgen.genfiles
      end
      if opts[:with_egmdo] || @driver_name =~ /egmdo|egdoe/
        @eggen._generate_code(gendir, opts)
        @genfiles += @eggen.genfiles
      end
      if package_dir? && @framework == 'openmdao'
        _generate_package_files(gendir)
      end
      @genfiles
    end

    def _generate_discipline(discipline, gendir, options = {})
      @discipline = discipline  # @discipline used in template
      @dimpl = @discipline.openmdao_impl || OpenmdaoDisciplineImpl.new
      @with_server = options[:with_server]
      if @discipline.type == "metamodel"
        _generate(discipline.py_filename, "openmdao_metamodel.py.erb", gendir)
      else
        _generate(discipline.py_filename, "openmdao_discipline.py.erb", gendir)
      end
      _generate(discipline.py_basefilename, "openmdao_discipline_base.py.erb", gendir)
    end

    # options: sqlite_filename=nil
    def _generate_sub_analysis(super_discipline, gendir, options = {})
      mda = super_discipline.sub_analysis
      sub_ogen = OpenmdaoGenerator.new(mda, server_host: @server_host, remote_ip: @remote_ip, 
        pkg_format: !@pkg_prefix.blank?, driver_name: @driver_name, driver_options: @driver_options)
      gendir = File.join(gendir, mda.basename)
      Dir.mkdir(gendir) unless Dir.exist?(gendir)

      # generate only analysis code: no script , no server
      opts = options.merge(with_run: false, with_server: false, with_runops: false)
      sub_ogen._generate_code(gendir, opts)
      @genfiles += sub_ogen.genfiles
    end

    def _generate_main(gendir, options = {})
      _generate(@mda.py_filename, "openmdao_analysis.py.erb", gendir)
      _generate(@mda.py_basefilename, "openmdao_analysis_base.py.erb", gendir)
      _generate("__init__.py", "__init__.py.erb", gendir)
    end

    # options: sqlite_filename: nil, with_runops: true, with_run: true
    def _generate_run_scripts(gendir, options = {})
      if options[:with_run]
        _generate("mda_init.py", "mda_init.py.erb", gendir)
        _generate("run_mda.py", "run_mda.py.erb", gendir)
      end
      if @driver_name # coming from GUI running remote driver
        @driver = OpenmdaoDriverFactory.new(@driver_name, @driver_options).create_driver
        if @driver.optimization?
          @sqlite_filename = options[:sqlite_filename] || "#{@mda.basename}_mdo.sqlite"
          _generate("run_mdo.py", "run_mdo.py.erb", gendir)
        elsif @driver.doe?
          @sqlite_filename = options[:sqlite_filename] || "#{@mda.basename}_doe.sqlite"
          _generate("run_doe.py", "run_doe.py.erb", gendir)
        else
          # should be simple run_once driver
          if @driver.class != WhatsOpt::OpenmdaoRunOnceDriver
            raise RuntimeError.new("Ouch! Should be run_once driver got #{@driver.inspect}")  
          end
        end
      elsif (options[:with_runops] || @mda.is_root_analysis?)
        @driver = OpenmdaoDriverFactory.new(DEFAULT_DOE_DRIVER).create_driver
        @sqlite_filename = options[:sqlite_filename] || "#{@mda.basename}_doe.sqlite"
        if @mda.uq_mode?
          _generate("run_doe.py", "run_uq_doe.py.erb", gendir)
        else
          _generate("run_doe.py", "run_doe.py.erb", gendir)
          if @mda.is_root_analysis?
            @driver = OpenmdaoDriverFactory.new(@impl.optimization_driver).create_driver
            @sqlite_filename = options[:sqlite_filename] || "#{@mda.basename}_mdo.sqlite"
            _generate("run_mdo.py", "run_mdo.py.erb", gendir)
          end
        end
      end
      if (options[:with_runops] || @mda.is_root_analysis?) && @mda.has_design_variables?
        @sqlite_filename = options[:sqlite_filename] || "#{@mda.basename}_screening.sqlite"
        _generate("run_screening.py", "run_screening.py.erb", gendir)
      end
    end

    def _generate_test_scripts(discipline, gendir)
      tests_dir = File.join(gendir, "tests")
      Dir.mkdir(tests_dir) unless File.exist?(tests_dir)
      @discipline = discipline  # @discipline used in template
      _generate("test_#{discipline.py_filename}", "test_discipline.py.erb", tests_dir)
    end

    def _generate_package_files(gendir)
      if @mda.packaged?
        # Package is attached, use it!
        @genfiles |= WhatsOpt::PackageExtractor.new(@mda).extract(gendir)
      else 
        # no package => generate package skeleton
        _generate(".gitignore", "package/gitignore.erb", gendir, no_comment: true)
        _generate("README", "package/README.erb", gendir, no_comment: true)
        _generate("setup.py", "package/setup.py.erb", gendir)
      end
    end

  end
end
