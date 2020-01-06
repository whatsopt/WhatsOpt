# frozen_string_literal: true

module WhatsOpt
  class OpenturnsSensitivityAnalyser 
    def initialize(ope_pce)
      if ope_pce.base_operation && ope_pce.base_operation.driver == "openturns_metamodel_pce"
        @mm = ope_pce.base_operation.meta_model
      else
        raise "Bad operation: openturns metamodel pce driver required for openturns sensitivity analyzer (got #{ope_pce.base_operation.driver})"
      end
    end

    def run
      ok, out, err = false, "{}", ""
      ok, err = check_metamodel
      if ok
        sa = {saMethod: 'sobol', saResult: get_sobol_pce_sensitivity_analysis}
      end
      return ok, sa, err
    end

    def check_metamodel
      if @mm.default_surrogate_kind == Surrogate::OPENTURNS_PCE
        return true, ""
      else
        return false, "Can not compute sensitivity: metamodel should be OPENTURNS PCE (got #{@mm.default_surrogate_kind})"
      end
    end

    def get_sobol_pce_sensitivity_analysis
      @mm.surrogates.inject({}){|acc, surr| acc.update(surr.get_sobol_pce_sensitivity_analysis)}
    end

  end
end
