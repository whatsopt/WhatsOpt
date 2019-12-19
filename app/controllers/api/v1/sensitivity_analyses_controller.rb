# frozen_string_literal: true

require "whats_opt/salib_sensitivity_analyser"
require "whats_opt/openturns_sensitivity_analyser"

class Api::V1::SensitivityAnalysesController < Api::ApiController
  # GET /api/v1/{operation_id}/sensitivity_analyses
  def show
    ope = Operation.find(params[:operation_id])
    Rails.logger.info ope
    authorize ope
    sensitivity_infos = _get_sensitivity_analyses_infos(analysis)
    render json: sensitivity_infos, status: :ok
  end

  private

  def _get_sensitivity_analyses_infos(ope)
    case ope.category
    when Operation::CAT_SCREENING:
      if ope.driver =~ /salib_doe_morris/   # TODO: add salib_doe_sobol
        analyser = WhatsOpt::SalibSensitivityAnalyser.new(ope)
        status, sa, err = analyser.run(kind: morris)
        return { statusOk: status, sensitivity: sa, error: err }
      end
    when Operation::CAT_METAMODEL:
      if ope.driver =~ /openturns_metamodel_pce/
        analyser = WhatsOpt::OpenturnsSensitivityAnalyser.new(ope)
        status, sa, err = analyser.run
        return { statusOk: status, sensitivity: sa, error: err }
      end
    end 
    return { statusOk: false, sensitivity: sa, error: "Bad operation category: #{ope.category}" }
  end

end