class DesignProjectsController < ApplicationController
  before_action :set_design_project, only: [:show, :edit, :update, :destroy]

  # GET /design_projects
  def index
    @design_projects = policy_scope(DesignProject)
  end

  # GET /design_projects/1
  def show
  end

  # GET /design_projects/new
  def new
    @design_project = DesignProject.new
    authorize @design_project
  end

  # GET /design_projects/1/edit
  def edit
  end

  # POST /design_projects
  def create
    @design_project = DesignProject.new(design_project_params)
    authorize @design_project
    if params[:cancel_button]
      redirect_to design_projects_url, notice: "Design Project creation cancelled."
    else
      if @design_project.save
        @design_project.set_owner(current_user)
        redirect_to design_projects_url, notice: "Design project #{@design_project.name} was successfully created."
      else
        redirect_to new_design_project_url, error: "Something went wrong while creating #{@design_project.name}."
      end
    end
  end

  # PATCH/PUT /design_projects/1
  def update
    if @design_project.update(design_project_params)
      redirect_to design_projects_url, notice: "Design project #{@design_project.name} was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /design_projects/1
  def destroy
    @design_project.destroy
    redirect_to design_projects_url, notice: "Design project #{@design_project.name} was successfully deleted."
  end

private
  def set_design_project
    @design_project = DesignProject.find(params[:id])
    authorize @design_project
  end

  def design_project_params
    params.require(:design_project).permit(:name, :description)
  end

end
