# frozen_string_literal: true

require "whats_opt/sensitivity_analysis_generator"

class Api::V1::OpenmdaoScreeningsController < Api::ApiController
  # GET /api/v1/operations/{operation_id}/openmdao_screenings/new
  def new
    ope = Operation.find(params[:operation_id])
    authorize ope
    sagen = WhatsOpt::SensitivityAnalysisGenerator.new(ope)
    status, sa, err = sagen.analyze_sensitivity
    render json: { statusOk: status, sensitivity: sa, error: err }, status: :ok
  end
end
