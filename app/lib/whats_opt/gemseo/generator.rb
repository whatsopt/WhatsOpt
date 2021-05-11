# frozen_string_literal: true

require "whats_opt/code_generator"
require "whats_opt/server_generator"

module WhatsOpt::Gemseo
  class Generator < WhatsOpt::CodeGenerator
    DEFAULT_DOE_DRIVER = :smt_doe_lhs
    DEFAULT_OPTIMIZATION_DRIVER = :scipy_optimizer_slsqp

    class DisciplineNotFoundException < StandardError
    end

    class NotYetImplementedError < StandardError
    end

    def initialize(mda, server_host: nil, driver_name: nil, driver_options: {},
                   whatsopt_url: "", api_key: "", remote_ip: "")
      super(mda)
      @prefix = "gemseo"
      @server_host = server_host
      @remote = !server_host.nil?
      @whatsopt_url = whatsopt_url
      @api_key = api_key
      @remote_ip = remote_ip
      @check_only = false
    end

    def run(method = "analysis", sqlite_filename = nil)
      ok, lines = false, []
      Dir.mktmpdir("run_#{@mda.basename}_#{method}") do |dir|
        dir='/tmp' # for debug
        begin
          _generate_code(dir, sqlite_filename: sqlite_filename)
        rescue ServerGenerator::ThriftError => e
          ok = false
          lines = e.to_s.lines.map(&:chomp)
        else
          ok, log = _run_mda(dir, method)
          lines = log.lines.map(&:chomp)
        end
      end
      return ok, lines
    end

    # sqlite_filename: nil, with_run: true, with_server: true, with_runops: true
    def _generate_code(gendir, options = {})
      opts = { with_server: true, with_run: true, with_unittests: false }.merge(options)
      @mda.disciplines.nodes.each do |disc|
        if disc.has_sub_analysis?
          raise NotYetImplementedError.new("Cannot generate code for sub_analysis #{@disc.name}")
          _generate_sub_analysis(disc, gendir, opts)
        else
          _generate_discipline(disc, gendir, opts)
          raise NotYetImplementedError.new("Cannot generate code for unit test #{@disc.name}") if opts[:with_unittests]
        end
      end
      _generate_main(gendir, opts)
      _generate_run_scripts(gendir, opts)
      if opts[:with_server] || (!@check_only && @mda.has_remote_discipline?(@remote_ip))
        p "COCUOCU #{!@check_only} #{@mda.has_remote_discipline?(@remote_ip)}"
        raise NotYetImplementedError.new("Cannot generate code for server")
      end
      @genfiles
    end

    def _generate_discipline(discipline, gendir, options = {})
      @discipline = discipline  # @discipline used in template
      @with_server = options[:with_server]
      if @discipline.type == "metamodel"
        raise NotYetImplementedError.new("Cannot generate code for metamodel #{@discipline.name}")
      else
        _generate(discipline.py_filename, "gemseo/gemseo_discipline.py.erb", gendir)
      end
      _generate(discipline.py_basefilename, "gemseo/gemseo_discipline_base.py.erb", gendir)
    end

    def _generate_main(gendir, options = {})
      _generate(@mda.py_filename, "gemseo/gemseo_main.py.erb", gendir)
      _generate(@mda.py_basefilename, "gemseo/gemseo_main_base.py.erb", gendir)
      _generate("__init__.py", "__init__.py.erb", gendir)
    end

    # options: with_runops: true, with_run: true
    def _generate_run_scripts(gendir, options = {})
      if options[:with_run]
        _generate("run_parameters_init.py", "run_parameters_init.py.erb", gendir)
        _generate("run_analysis.py", "gemseo/run_analysis.py.erb", gendir)
      end
      if (options[:with_runops] || @mda.is_root_analysis?) && @mda.has_decision_variables?
        if @mda.is_root_analysis? && @mda.has_objective?
          _generate("run_doe.py", "gemseo/run_doe.py.erb", gendir)
          _generate("run_optimization.py", "gemseo/run_optimization.py.erb", gendir)
        end
      end
    end

  end
end
