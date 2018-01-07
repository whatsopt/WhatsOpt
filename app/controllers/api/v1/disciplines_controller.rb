class Api::V1::DisciplinesController < Api::ApiController
  before_action :set_discipline, only: [:update, :destroy]

  # GET /disciplines/1
  def show
    json_response @discipline
  end
  
  # POST /disciplines
  def create
    mda = Analysis.find(params[:mda_id])
    @discipline = Discipline.create!(discipline_params)
    json_response @discipline, :created
  end

  # PATCH/PUT /disciplines/1
  def update
    @discipline.update(discipline_params)
    head :no_content
  end

  # DELETE /disciplines/1
  def destroy
    @discipline.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_discipline
      @discipline = Discipline.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def discipline_params
      params.require(:discipline).permit(:name, :analysis_id)
    end
end
