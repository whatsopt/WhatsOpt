class NotebooksController < ApplicationController
  def index
    @notebooks = Notebook.all
  end
  
  def show
    @notebook = Notebook.find(params[:id]);
  end

  def new
    @notebook = Notebook.new
  end
  
  def create
    if params[:cancel_button]
      flash[:notice] = "Notebook creation cancelled."
      redirect_to notebooks_url
    else 
      @notebook = Notebook.create(notebook_params)
      if @notebook.save
        current_user.add_role(:owner, @notebook)
        current_user.save
        flash[:notice] = "Notebook created"
        redirect_to notebook_url(@notebook)
      else
        flash[:error] = "Notebook creation failed: invalid input data."
        render :action => 'new'
      end
    end
  end
  
  def edit
    @notebook = Notebook.find(params[:id])
  end
  
  def update
    @notebook = Notebook.find(params[:id])
    @notebook.name = params[:user][:name] unless params[:user][:name].blank?
    if @notebook.save
      flash[:notice] = "Successfully updated notebook."
      redirect_to notebook_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @notebook = Notebook.find(params[:id])
    @notebook.destroy
    flash[:notice] = "Successfully deleted project."
    redirect_to notebooks_url
  end

  private

  def notebook_params
    params.fetch(:notebook, {}).permit(:attachment_attributes => [:id, :data, :_destroy])   
  end
    
end

