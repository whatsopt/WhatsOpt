class GeometryModelsController < ApplicationController
  before_action :set_geomodel, only: [:show, :edit, :update, :destroy]
    
  # GET /geometry_models
  def index
    @geomodels = policy_scope(GeometryModel)
  end
  
  # GET /geometry_models/1
  def show
  end

  # GET /geometry_models/new
  def new
    @geomodel = GeometryModel.new
    authorize @geomodel
  end
  
  # GET /geometry_models/1/edit
  def edit
  end
  
  # POST /geometry_models
  def create
    if params[:cancel_button]
      redirect_to geometry_models_url, notice: "GeometryModel import cancelled."
    else 
      @geomodel = GeometryModel.new(geomodel_params)
      authorize @geomodel
      if @geomodel.save
        current_user.add_role(:owner, @geomodel)
        current_user.save
        redirect_to geometry_model_url(@geomodel), notice: "GeometryModel was successfully imported."
      else
        flash[:error] = "GeometryModel import failed: invalid input data."
        render :action => 'new'
      end
    end
  end
  
  # PATCH/PUT /geometry_models/1
  def update
    if params[:cancel_button]
      redirect_to geometry_model_url, notice: "Geometry Model update cancelled."
    else  
      if @geomodel.update(geomodel_params)
        flash[:notice] = "Successfully updated Geometry Model."
        redirect_to geometry_model_url
      else
        render :action => 'edit'
      end
    end
  end
  
  # DELETE /geometry_models/1
  def destroy
    @geomodel.destroy
    flash[:notice] = "Successfully deleted project."
    redirect_to geometry_models_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_geomodel
    @geomodel = GeometryModel.find(params[:id])
    authorize @geomodel
  end
  
  def geomodel_params
    params.fetch(:geometry_model, {}).permit(:title, :attachment_attributes => [:id, :data, :_destroy])   
  end
    
end
