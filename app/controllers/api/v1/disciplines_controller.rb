# frozen_string_literal: true

class Api::V1::DisciplinesController < Api::ApiController
  before_action :set_discipline, only: [:show, :update, :destroy]

  # GET /api/v1/disciplines/1
  def show
    json_response @discipline
  end

  # POST /api/v1/{mda_id}/disciplines
  def create
    mda = Analysis.find(params[:mda_id])
    authorize mda
    @discipline = mda.disciplines.create!(discipline_params)
    json_response @discipline, :created
  end

  # PATCH/PUT /api/v1/disciplines/1
  def update
    @discipline.update_discipline(discipline_params)
    head :no_content
  end

  # DELETE /api/v1/disciplines/1
  def destroy
    # @discipline.destroy!
    @discipline.analysis.destroy_discipline!(@discipline)
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_discipline
      @discipline = Discipline.find(params[:id])
      authorize @discipline
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def discipline_params
      params.require(:discipline).permit(:name, :analysis_id, :type, :position, endpoint_attributes: [:id, :host, :port, :_destroy])
    end
end
