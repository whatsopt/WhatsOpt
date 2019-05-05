require 'whats_opt/code_generator'

module WhatsOpt  
  class SensitivityAnalysisGenerator < CodeGenerator
    
    def initialize(ope, input_cases: nil, output_cases: nil, options: {})
      super(ope.analysis)
      @prefix='sensitivity_analysis'
      @input_varcases = input_cases || ope.input_cases
      @output_varcases = output_cases || ope.output_cases
    end

    def _generate_code(gendir, options={})
      _generate("run_sensitivity_analysis.py", 'run_sensitivity_analysis.py.erb', gendir)
    end    

  end  
end
