# frozen_string_literal: true

require "whats_opt/code_generator"

module WhatsOpt
  class OpenturnsSensitivityAnalyser < CodeGenerator
    def initialize(ope)
      super(ope.analysis)
      @input_varcases = ope.input_cases
      @output_varcases = ope.output_cases
      Rails.logger.info @input_varcases.map(&:float_varname)
      Rails.logger.info @output_varcases.map(&:float_varname)
    end

    def run
      ok, out, err = false, "{}", ""
      Dir.mktmpdir("run_#{@mda.basename}_openturns_sensitivity_analysis") do |dir|
        dir = "/tmp" # for debug
        _generate_code(dir)
        ok, out, err = _run_sensitivity_analysis(dir)
      end
      # Rails.logger.info out
      # out = "nil" if out == ""
      # outjson = "null"
      # begin
      #   outjson = JSON.parse(out)
      # rescue
      #   outjson = "null"
      # end
      # Rails.logger.info outjson
      return ok, outjson, err
    end

    def _generate_code(gendir, options = {})
      _generate("run_sensitivity_analysis.py", "run_openturns_sensitivity_analysis.py.erb", gendir)
    end

    def _run_sensitivity_analysis(dir)
      script = File.join(dir, "run_sensitivity_analysis.py")
      Rails.logger.info "#{PYTHON} #{script}"
      stdout, stderr, status = Open3.capture3(PYTHON, script)
      return status.success?, stdout.chomp, stderr.lines.map(&:chomp)
    end
  end
end
