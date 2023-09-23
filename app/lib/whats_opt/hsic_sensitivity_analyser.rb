# frozen_string_literal: true

require "matrix"

module WhatsOpt
  class HsicSensitivityAnalyser
    def initialize(ope_doe)
      if ope_doe.doe?
        @ope = ope_doe
        @proxy = SensitivityAnalyserProxy.new
      else
        raise "Bad operation: doe operation required for hsic sensitivity analyzer (got #{ope_pce.base_operation.driver})"
      end
    end

    def get_hsic_sensitivity(thresholding=Services::HsicThresholding::ZERO, quantile=0.2, g_threshold=0.0)
      ok, err = true, ""

      # xdoe from cases
      xdata = @ope.input_cases.map {|c| c.values}
      xdoe = Matrix[*xdata].t

      # objective from cases 
      # XXX: suppose mono-objective
      obj_vars = @ope.cases.with_role_case(WhatsOpt::Variable::MIN_OBJECTIVE_ROLE)
      obj_vals = obj_vars.map {|c| c.values}
      # cstrs from cases
      # XXX: works only for negative constraints
      cstrs_vars = @ope.cases.with_role_case(WhatsOpt::Variable::NEG_CONSTRAINT_ROLE)
      cstrs_vals = cstrs_vars.map {|c| c.values}
      ydoe = (Matrix[*obj_vals].vstack(Matrix[*cstrs_vals])).t

      hsic = @proxy.compute_hsic(xdoe.to_a, ydoe.to_a, thresholding, quantile, g_threshold)
      return ok, hsic, err
    rescue StandardError => e
      return false, {}, e.to_s
    end

  end
end

  