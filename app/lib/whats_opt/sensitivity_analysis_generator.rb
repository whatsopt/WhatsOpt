require 'whats_opt/code_generator'

module WhatsOpt  
  class SensitivityAnalysisGenerator < CodeGenerator
    
    def initialize(mda, server_host=nil)
      super(mda, server_host)
      @prefix='sensitivity_analysis'
    end

    def _generate_code(gendir, options={})
      _generate("run_sensitivity_analysis.py", 'run_sensitivity_analysis.py.erb', server_dir)
    end    
    
  end  
end
