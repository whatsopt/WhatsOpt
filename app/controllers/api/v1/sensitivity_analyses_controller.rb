# frozen_string_literal: true

require "whats_opt/salib_sensitivity_analyser"
# require "whats_opt/openturns_sensitivity_analyser"

class Api::V1::SensitivityAnalysesController < Api::ApiController
  # GET /api/v1/{operation_id}/sensitivity_analysis
  def show
    ope = Operation.find(params[:operation_id])
    authorize ope.analysis
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
        elsif ope.driver && ope.driver.to_s.include?("openturns_sensitivity_pce")
          analyser = WhatsOpt::OpenturnsSensitivityAnalyser.new(ope)
          status, sa, err = analyser.run
          return { statusOk: status, sensitivity: sa, error: err }
        end
      when Operation::CAT_DOE
        analyser = WhatsOpt::HsicSensitivityAnalyser.new(ope)
        thresholding = case params[:thresholding]
        when "Zero_th"
          WhatsOpt::Services::HsicThresholding::ZERO
        when "Cond_th"
          WhatsOpt::Services::HsicThresholding::COND
        when "Ind_th"
          WhatsOpt::Services::HsicThresholding::IND
        else
          err_msg = "Unknown thresholding type: should be [Zero|Cond|Ind]_th, got #{params[:thresholding]}"
          Rails.logger.error "Unknown thresholding type: should be [Zero|Cond|Ind]_th, got #{params[:thresholding]}"
        end
        quantile = params[:quantile].to_f
        g_threshold = params[:g_threshold].to_f
        status, sa, err_msg = analyser.get_hsic_sensitivity(thresholding, quantile, g_threshold)
        return { statusOk: status, sensitivity: sa, error: err_msg }
      end
      { statusOk: false, sensitivity: {},
               error: "Bad operation category: Should be #{Operation::CAT_SENSITIVITY} or #{Operation::CAT_DOE} (got #{ope.category})" }
    end
end
