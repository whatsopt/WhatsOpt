# frozen_string_literal: true

require "whats_opt/salib_sensitivity_analyser"
#require "whats_opt/openturns_sensitivity_analyser"

class Api::V1::SensitivityAnalysesController < Api::ApiController
  # GET /api/v1/{operation_id}/sensitivity_analysis
  def show
    ope = Operation.find(params[:operation_id])
    Rails.logger.info ope.inspect
    authorize ope
    sensitivity_infos = _get_sensitivity_analysis_infos(ope)
    if sensitivity_infos[:statusOk]
      render json: sensitivity_infos, status: :ok
    else
      render json: sensitivity_infos, status: :unprocessable_entity
    end
  end

  private

  def _get_sensitivity_analysis_infos(ope)
    case ope.category
    when Operation::CAT_SENSITIVITY
      if ope.driver =~ /salib_sensitivity_(sobol|morris)/ 
        analyser = WhatsOpt::SalibSensitivityAnalyser.new(ope, kind: $1.to_sym)
        status, sa, err = analyser.run
        return { statusOk: status, sensitivity: sa, error: err }
      elsif ope.driver =~ /openturns_sensitivity_pce/
        analyser = WhatsOpt::OpenturnsSensitivityAnalyser.new(ope)
        status, sa, err = analyser.run
        return { statusOk: status, sensitivity: sa, error: err }
      end
    end 
    return { statusOk: false, sensitivity: sa, 
             error: "Bad operation category: Should be #{Operation::CAT_SENSITIVITY} (got #{ope.category})" }
  end

end