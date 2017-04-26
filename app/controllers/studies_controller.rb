class StudiesController < ApplicationController    
  
  def index
    @studies = Study.all
  end
  
  def show
    @study = Study.find(params[:id]);
  end

  def new
    @study = Study.new
  end
  
  def edit
    @study = Study.find(params[:id])
  end
  
  def create
    if params[:cancel_button]
      flash[:notice] = "Study creation cancelled."
      if params[:project_id] && Project.find(project_id)
        redirect_to Project.find(params[:project_id])
      else
        redirect_to Project.find_by(name: 'Scratch')
      end
    else
      @study = Study.create(study_params)
      if params[:project_id] && Project.find(project_id)
        @study.project = Project.find(project_id)
      else
        @study.project = Project.find_by(name: 'Scratch')
      end
      if @study.save
        flash[:notice] = "Study created in project #{@study.project.name}"
        redirect_to study_url(@study)
      else
        flash[:error] = "Study creation failed: invalid input data."
        render :action => 'new'
      end
    end
  end
  
  def update
    @study = Study.find(params[:id])
    @study.name = params[:user][:name] unless params[:user][:name].blank?
    if @study.save
      flash[:notice] = "Successfully updated project."
      redirect_to studies_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @study = Study.find(params[:id])
    @study.destroy
    flash[:notice] = "Successfully deleted project."
    redirect_to studies_url
  end

  private

  def study_params
    params.require(:study).permit(:name, :attachments_attributes => [:id, :data, :_destroy])
  end
    
end
