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
      redirect_to mdas_url, notice: "Analysis creation cancelled."
    else 
      @mda = Analysis.new(mda_params)
      if @mda.save
        #Connection.create_connections(@mda)
        current_user.add_role(:owner, @mda)
        current_user.save
        if @mda.disciplines.nodes.empty?
          redirect_to edit_mda_url(@mda)
        else
          redirect_to mda_url(@mda), notice: "Analysis #{@mda.name} was successfully created."
        end
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
    def set_mda
      @mda = Analysis.find(params[:id])
    end

    def mda_params
      params.require(:analysis)
        .permit(:name, :attachment_attributes => [:id, :data, :_destroy])
    end
end
