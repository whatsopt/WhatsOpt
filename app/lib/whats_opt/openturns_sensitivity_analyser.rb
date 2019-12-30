# frozen_string_literal: true

require "whats_opt/surrogate"

module WhatsOpt
  class OpenturnsSensitivityAnalyser 
    def initialize(pce_metamodel)
      @mm = metamodel
    end

    def run
      ok, out, err = false, "{}", ""
      ok, err = check_metamodel
      if ok
        sa = @mm.get_sobol_pce_sensitivity_analysis
      end
      return ok, sa, err
    end

    def check_metamodel
      if @mm.default_surrogate_kind == WhatsOpt::Surrogate::SURROGATE_OPENTURNS_PCE
        return true, ""
      begin
        return false, "Can not compute sensitivity: metamodel should be OPENTURNS PCE (got #{@mm.default_surrogate_kind})"
      end
    end

  end
end
