# frozen_string_literal: true

require "whats_opt/code_generator"

module WhatsOpt
  class SensitivityAnalysisGenerator < CodeGenerator
    def initialize(ope, input_cases: nil, output_cases: nil, options: {})
      super(ope.analysis)
      @prefix = "sensitivity_analysis"
      @input_varcases = input_cases || ope.input_cases
      @output_varcases = output_cases || ope.output_cases
      Rails.logger.info @input_varcases.map(&:float_varname)
      Rails.logger.info @output_varcases.map(&:float_varname)
    end

    def analyze_sensitivity
      ok, out, err = false, "{}", ""
      Dir.mktmpdir("run_#{@mda.basename}_screening") do |dir|
        dir = "/tmp" # for debug
        _generate_code(dir)
        ok, out, err = _run_screening(dir)
      end
      Rails.logger.info out
      out = "nil" if out == ""
      outjson = "null"
      begin
        outjson = JSON.parse(out)
      rescue
        outjson = "null"
      end
      Rails.logger.info outjson
      return ok, outjson, err
    end

    def _generate_code(gendir, options = {})
      _generate("run_sensitivity_analysis.py", "run_sensitivity_analysis.py.erb", gendir)
    end

    def _run_screening(dir)
      script = File.join(dir, "run_sensitivity_analysis.py")
      Rails.logger.info "#{PYTHON} #{script}"
      stdout, stderr, status = Open3.capture3(PYTHON, script)
      return status.success?, stdout.chomp, stderr.lines.map(&:chomp)
    end
  end
end
