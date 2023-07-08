# frozen_string_literal: true

require "whats_opt/code_generator"

module WhatsOpt
  class EgmdoGenerator < CodeGenerator

    def initialize(mda, pkg_format: false, remote_operation: false, outdir: ".", driver_name: nil, driver_options: {})
      super(mda, pkg_format: pkg_format)
      @remote = remote_operation
      @outdir = outdir
      @driver_name = driver_name.to_sym if driver_name
      @driver_options = driver_options
      @prefix = "egmdo"
      @impl = @mda.openmdao_impl || OpenmdaoAnalysisImpl.new(analysis: @mda)
      @egmdo = true
    end

    # sqlite_filename: nil, with_run: true, with_server: true, with_runops: true
    def _generate_code(gendir, options = {})
      pkg_dir = package_dir? ? File.join(gendir, @impl.py_modulename) : gendir
      Dir.mkdir(pkg_dir) unless Dir.exist?(pkg_dir)
      egmdo_dir = File.join(pkg_dir, @egmdo_module)
      Dir.mkdir(egmdo_dir) unless File.exist?(egmdo_dir)
      _generate("#{@impl.py_modulename}_egmda.py", "egmdo/openmdao_egmda.py.erb", egmdo_dir)
      _generate("run_egmda.py", "run_mda.py.erb", gendir)
      _generate("algorithms.py", "egmdo/algorithms.py.erb", egmdo_dir)
      _generate("doe_factory.py", "egmdo/doe_factory.py.erb", egmdo_dir)
      _generate("gp_factory.py", "egmdo/gp_factory.py.erb", egmdo_dir)
      _generate("random_analysis.py", "egmdo/random_analysis.py.erb", egmdo_dir)
      _generate("random_vec_analysis.py", "egmdo/random_vec_analysis.py.erb", egmdo_dir)
      _generate("__init__.py", "__init__.py.erb", egmdo_dir)
      if @driver_name
        @driver = OpenmdaoDriverFactory.new(@driver_name, @driver_options).create_driver
        if @driver.optimization?
          @sqlite_filename = options[:sqlite_filename] || "#{@mda.impl.basename}_mdo.sqlite"
          _generate("run_egmdo.py", "run_mdo.py.erb", gendir)
        elsif @driver.doe?
          @sqlite_filename = options[:sqlite_filename] || "#{@mda.impl.basename}_doe.sqlite"
          _generate("run_egdoe.py", "run_doe.py.erb", gendir)
        else
          raise RuntimeError.new("Ouch! Should be egmdo or egdoe driver got #{@driver.inspect}")  
        end
      else
        @sqlite_filename = "#{@mda.impl.basename}_egdoe.sqlite"
        @driver = OpenmdaoDriverFactory.new(DEFAULT_DOE_DRIVER).create_driver
        _generate("run_egdoe.py", "run_doe.py.erb", gendir)
        @sqlite_filename = "#{@mda.impl.basename}_egmdo.sqlite"
        @driver = OpenmdaoDriverFactory.new(@impl.optimization_driver).create_driver
        _generate("run_egmdo.py", "run_mdo.py.erb", gendir)
      end
    end

  end
end
