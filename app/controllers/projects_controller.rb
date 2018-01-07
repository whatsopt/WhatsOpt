class ProjectsController < ApplicationController    
  before_action :set_project, only: [:show, :edit, :update, :destroy]
    
  def index
    @projects = Project.all
  end
  
  def show
    @project = Project.find(params[:id]);
  end

  def new
    @project = Project.new
  end
  
  def edit
    @project = Project.find(params[:id])
  end
  
  def create
    if params[:cancel_button]
      flash[:notice] = "Project creation cancelled."
      redirect_to projects_url
    else
      @project = Project.new do |p|  
        p.name = params[:name]
        p.description = params[:name]
      end
      if @project.save
        flash[:notice] = "Creation successful."
        redirect_to projects_url
      else
        render :action => 'new'
      end
    end
  end
  
  def update
    @project = Project.find(params[:id])
    @project.name = params[:user][:name] unless params[:user][:name].blank?
    @project.description = params[:user][:description] unless params[:user][:description].blank?
    if @project.save
      flash[:notice] = "Successfully updated project."
      redirect_to projects_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    flash[:notice] = "Successfully deleted project."
    redirect_to projects_url
  end 
  
  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name, :analisys_id)
  end
end
