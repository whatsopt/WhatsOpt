class Api::V1::AnalysesController < Api::ApiController 

  before_action :set_mda, only: [:show, :update]
  
  # GET /api/v1/mda/1
  def show
    if params[:format] == 'xdsm'
      render json: @mda.to_mda_viewer_json
    else
      json_response @mda
    end
  end
  
  # GET /api/v1/mdas
  def index
    @mdas = Analysis.all
    json_response @mdas
  end
  
  # POST /api/v1/mdas
  def create
    @mda = Analysis.create!(mda_params)
    current_user.add_role(:owner, @mda)
    current_user.save!
    json_response @mda, :created
  end

  # PUT/PATCH /api/v1/mdas/1
  def update
    authorize @mda
    @mda.update!(mda_params)
    head :no_content
  end
  
  private

    def set_mda
      @mda = Analysis.find(params[:id])
    end
  
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