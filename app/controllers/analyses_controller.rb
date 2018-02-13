class AnalysesController < ApplicationController
  before_action :set_mda, only: [:show, :edit, :update, :destroy]

  # GET /mdas
  def index
    @mdas = Analysis.all
  end

  # GET /mdas/1
  def show
  end

  # GET /mdas/new
  def new
    @import = !!params[:import]
    @mda = Analysis.new
  end

  # GET /mdas/1/edit
  def edit
  end

  # POST /mdas
  def create
    if params[:cancel_button]
      redirect_to mdas_url, notice: "MDA creation cancelled."
    else 
      @mda = Analysis.new(mda_params)
      if @mda.save
        Connections.create_connections(@mda) if @import
        current_user.add_role(:owner, @mda)
        current_user.save
        redirect_to mda_url(@mda), notice: 'MDA was successfully created.'
      else
        @import = params[:import]
        render :new
      end
    end
  end

  # PATCH/PUT /mdas/1
  def update
    authorize @mda
    if @mda.update(mda_params)
      redirect_to mda_url(@mda), notice: 'MDA was successfully updated.' 
    else
      render :edit 
    end
  end

  # DELETE /mdas/1
  def destroy
    authorize @mda
    @mda.destroy
    redirect_to mdas_url, notice: 'MDA was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mda
      @mda = Analysis.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mda_params
      params.require(:analysis)
        .permit(:name, :attachment_attributes => [:id, :data, :_destroy], 
                       :disciplines_attributes => [:id, :name, :_destroy])
    end
end
