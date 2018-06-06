class OperationsController < ApplicationController
  before_action :set_ope, only: [:show, :destroy]

  # GET /operations/1
  def show
    @ope = Operation.find(params[:id])
    @mda = @ope.analysis
  end
  
  # GET /analyses/:mda_id/operations/new
  def new
    @mda = Analysis.find(params[:mda_id])
    @mda.operations.build
    @ope = @mda.operations.last
    @default_host = request.remote_ip
  end
  
  # POST /analyses/:mda_id/operations
  def create
    @mda = Analysis.find(params[:mda_id])
    @ope, @ok, @log = Operation.build_operation_from_run(@mda, request.remote_ip)
    if @ok 
      if @ope.save
        redirect_to operation_url(@ope)
      else
        redirect_to new_mda_operations_url(@mda)
      end
    else
      redirect_to new_mda_operation_url(@mda), alert: "Error in operation"
    end 
  end
  
  # DELETE /operations/1
  def destroy
    authorize @ope
    @ope.destroy
    redirect_to mdas_url, notice: 'Operation was successfully destroyed.'
  end
  
  private
  
    def set_ope
      @ope = Operation.find(params[:id])
    end

end
