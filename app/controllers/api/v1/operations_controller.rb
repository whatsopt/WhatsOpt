class Api::V1::OperationsController < Api::ApiController
  before_action :set_operation, only: [:show, :destroy]

  # GET /api/v1/operations/1
  def show
    json_response @operation
  end
  
  # POST /api/v1/{mda_id}/operations
  def create
    mda = Analysis.find(params[:mda_id])
    @operation = mda.operations.create!(name: params[:operation][:name])
    data = params[:operation].slice(:cases)
    @operation.create_cases!(data[:cases])
    render json: @operation, status: :created
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

end
