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
  
  def create
    if params[:cancel_button]
      flash[:notice] = "Study creation cancelled."
      redirect_to studies_url
    else
      @study = Study.new do |p|  
        p.name = params[:name]
        p.description = params[:name]
      end
      if @study.save
        flash[:notice] = "Creation successful."
        redirect_to studies_url
      else
        render :action => 'new'
      end
    end
  end
  
  def edit
    @study = Study.find(params[:id])
  end
  
  def update
    @study = Study.find(params[:id])
    @study.name = params[:user][:name] unless params[:user][:name].blank?
    @study.description = params[:user][:description] unless params[:user][:description].blank?
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
end
