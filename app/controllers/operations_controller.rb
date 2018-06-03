require 'whats_opt/openmdao_generator'

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
  end
  
  # POST /analyses/:mda_id/operations
  def create
    @mda = Analysis.find(params[:mda_id])
    @mda.operations.build
    @ope = @mda.operations.last
    ogen = WhatsOpt::OpenmdaoGenerator.new(@mda, remote=true)
    ogen.run_remote
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
