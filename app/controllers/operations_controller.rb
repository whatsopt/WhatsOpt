class OperationsController < ApplicationController
  before_action :set_ope, only: [:show, :destroy]

  # GET /operations/1
  def show
    @ope = Operation.find(params[:id])
    @mda = @ope.analysis
  end
  
  # GET /operations/new
  def new
    @ope = Operation.new
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
