# frozen_string_literal: true

require "whats_opt/code_generator"

module WhatsOpt
  class EgmdoGenerator < CodeGenerator

    def initialize(mda)
      super(mda)
      @prefix = "egmdo"
      @impl = @mda.openmdao_impl || OpenmdaoAnalysisImpl.new
      @egmdo = true
    end

    # sqlite_filename: nil, with_run: true, with_server: true, with_runops: true
    def _generate_code(gendir, options = {})
      if @mda.has_objective? && 
        !@mda.is_composite? && 
        !@mda.disciplines.select{|d| d.openmdao_impl&.egmdo_surrogate}.blank?

        egmdo_dir = File.join(gendir, @egmdo_module)
        Dir.mkdir(egmdo_dir) unless File.exist?(egmdo_dir)
        _generate("#{@mda.basename}_egmda.py", "egmdo/openmdao_egmda.py.erb", egmdo_dir)
        _generate("run_egmda.py", "run_analysis.py.erb", gendir)
        @sqlite_filename = "#{@mda.basename}_egdoe.sqlite"
        @driver = OpenmdaoDriverFactory.new(:smt_doe_lhs, {smt_doe_lhs_nbpts: 50}).create_driver
        _generate("run_egdoe.py", "run_doe.py.erb", gendir)
        @sqlite_filename = "#{@mda.basename}_egmdo.sqlite"
        @driver = OpenmdaoDriverFactory.new(:scipy_optimizer_slsqp, {}).create_driver
        _generate("run_egmdo.py", "run_optimization.py.erb", gendir)
        _generate("algorithms.py", "egmdo/algorithms.py.erb", egmdo_dir)
        _generate("doe_factory.py", "egmdo/doe_factory.py.erb", egmdo_dir)
        _generate("gp_factory.py", "egmdo/gp_factory.py.erb", egmdo_dir)
        _generate("random_analysis.py", "egmdo/random_analysis.py.erb", egmdo_dir)
        _generate("__init__.py", "__init__.py.erb", egmdo_dir)
      end
    end

  end
end
