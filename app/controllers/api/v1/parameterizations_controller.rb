# frozen_string_literal: true

class Api::V1::ParameterizationsController < Api::ApiController
  before_action :set_analysis

  # PATCH/PUT /api/v1/analysis/1/parameterization
  def update
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_analysis
      @mda = Analysis.find(params[:mda_id])
      authorize @mda
      @mda.parameterize(parameterization_params)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def parameterization_params
      params.require(:parameterization).permit(parameters: [:varname, :value])
    end
end
