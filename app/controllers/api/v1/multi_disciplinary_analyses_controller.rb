class Api::V1::MultiDisciplinaryAnalysesController < Api::ApiController 

  def show
    @mda = MultiDisciplinaryAnalysis.find(params[:id])
  end
  
  # POST /mdas
  def create
    @mda = MultiDisciplinaryAnalysis.create(mda_params)
    current_user.add_role(:owner, @mda)
    if @mda.save && current_user.save
      render json: @mda, status: :created, location: api_v1_mda_path(@mda)
    else
      render json: @mda.errors.update(current_user.errors)
    end
  end

  private

  def mda_params
    def mda_params
      params.require(:multi_disciplinary_analysis).permit(:name, :disciplines_attributes => [:name])
    end
  end 
  
end