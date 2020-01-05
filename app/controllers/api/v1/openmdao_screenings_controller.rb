# frozen_string_literal: true

# require "whats_opt/salib_sensitivity_analyser"

# class Api::V1::OpenmdaoScreeningsController < Api::ApiController
#   # GET /api/v1/operations/{operation_id}/openmdao_screening
#   def show
#     ope = Operation.find(params[:operation_id])
#     Rails.logger.info ope
#     authorize ope
#     analyser = WhatsOpt::SalibSensitivityAnalyser.new(ope)
#     status, sa, err = analyser.run
#     render json: { statusOk: status, sensitivity: sa, error: err }, status: :ok
#   end
# end
