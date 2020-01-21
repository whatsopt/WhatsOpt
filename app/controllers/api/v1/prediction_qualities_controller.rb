# frozen_string_literal: true

class Api::V1::PredictionQualitiesController < Api::ApiController
  # GET /api/v1/{meta_model_id}/prediction_quality
  def show
    mm = MetaModel.find(params[:meta_model_id])
    authorize mm
    quality = mm.qualification
    render json: quality, status: :ok
  end

end