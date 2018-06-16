class Api::V1::OperationsController < Api::ApiController
  before_action :set_operation, only: [:show, :update, :destroy]

  # GET /api/v1/operations/1
  def show
    json_response @operation
  end
  
  # POST /api/v1/{mda_id}/operations
  def create
    # called by wop upload data.sqlite
    mda = Analysis.find(params[:mda_id])
    @operation = Operation.build_operation(mda, ope_params)
    @operation.save!
    render json: @operation, status: :created
  end

  # PATCH /api/v1/operations/1
  def update
    OperationJob.perform_later(@operation) 
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
    end
  
    def ope_params
      params.require(:operation).permit(:host, :name, cases: [:varname, :coord_index, values: []])
    end
    
end
