class RunsController < ApplicationController    
  def index
    @runs = Run.all
  end
  
  def show
    @run = Run.find(params[:id]);
  end

  def new
    @run = Run.new
  end
  
  def create
    if params[:cancel_button]
      flash[:notice] = "Run creation cancelled."
      redirect_to runs_url
    else
      @run = Run.new do |p|  
        p.project_id = params[:project_id]
      end
      if @run.save
        flash[:notice] = "Creation successful."
        redirect_to runs_url
      else
        render :action => 'new'
      end
    end
  end
  
  def edit
    @run = Run.find(params[:id])
  end
  
  def update
    @run = Run.find(params[:id])
    if @run.save
      flash[:notice] = "Successfully updated run."
      redirect_to run_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @run = Run.find(params[:id])
    @run.destroy
    flash[:notice] = "Successfully deleted run."
    redirect_to runs_url
  end 
end
