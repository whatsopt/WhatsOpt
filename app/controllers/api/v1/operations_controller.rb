class Api::V1::OperationsController < Api::ApiController
  before_action :set_operation, only: [:show, :update, :destroy]

  # GET /api/v1/operations/1
  def show
    json_response @operation
  end
  
  # POST /api/v1/{mda_id}/operations
  def create
    mda = Analysis.find(params[:mda_id])
    authorize mda
    @operation = Operation.build_operation(mda, ope_params)
    @operation.save!
    render json: @operation, status: :created
  end

  # PATCH /api/v1/operations/1
  def update
    @operation.update_operation(ope_params)
    @operation.save!
    head :no_content
  end
  
  # DELETE /api/v1/operations/1
  def destroy
    @operation.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operation
      @operation = Operation.find(params[:id])
      authorize @operation
    end
  
    def ope_params
      params.require(:operation).permit(:host, :driver, :name, 
                                        cases: [:varname, :coord_index, values: []],
                                        success: [],
                                        options_attributes: [:id, :name, :value, :_destroy])
    end
    
end
