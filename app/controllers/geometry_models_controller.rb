class GeometryModelsController < ApplicationController
  before_action :set_geomodel, only: [:show, :edit, :update, :destroy]
    
  # GET /geometry_models
  def index
    @geomodels = GeometryModel.all
  end
  
  # GET /geometry_models/1
  def show
  end

  # GET /geometry_models/new
  def new
    @geomodel = GeometryModel.new
  end
  
  # GET /geometry_models/1/edit
  def edit
  end
  
  # POST /geometry_models
  def create
    if params[:cancel_button]
      redirect_to geometry_models_url, notice: "GeometryModel creation cancelled."
    else 
      @geomodel = GeometryModel.create(geomodel_params)
      if @geomodel.save
        current_user.add_role(:owner, @geomodel)
        current_user.save
        redirect_to geometry_model_url(@geomodel), notice: "GeometryModel was successfully created."
      else
        flash[:error] = "GeometryModel creation failed: invalid input data."
        render :action => 'new'
      end
    end
  end
  
  # PATCH/PUT /geometry_models/1
  def update
    authorize @geomodel
    if @geomodel.update(geomodel_params)
      flash[:notice] = "Successfully updated GeometryModel."
      redirect_to geometry_model_url
    else
      render :action => 'edit'
    end
  end
  
  # DELETE /geometry_models/1
  def destroy
    authorize @geomodel
    @geomodel.destroy
    flash[:notice] = "Successfully deleted project."
    redirect_to geometry_models_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_geomodel
    @geomodel = GeometryModel.find(params[:id])
  end
  
  def geomodel_params
    params.fetch(:geometry_model, {}).permit(:title, :attachment_attributes => [:id, :data, :_destroy])   
  end
    
end
