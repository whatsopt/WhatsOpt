class Api::V1::AnalysesController < Api::ApiController 

  def show
    @mda = Analysis.find(params[:id])
  end
  
  # POST /mdas
  def create
    @mda = Analysis.create!(mda_params)
    current_user.add_role(:owner, @mda)
    current_user.save
    json_response @mda
  end

  private

    def mda_params
      params.require(:analysis).permit(
      :name, 
      :disciplines_attributes => 
         [
          :name, 
          :variables_attributes => [:name, :fullname, :io_mode, :type, :shape, :units, :desc]
         ]
      )
    end
  
end