class NotebooksController < ApplicationController
  
  # GET /notebooks
  def index
    @notebooks = Notebook.all
  end
  
  # GET /notebooks/1
  def show
    @notebook = Notebook.find(params[:id]);
  end

  # GET /notebooks/new
  def new
    @notebook = Notebook.new
  end
  
  # GET /notebooks/1/edit
  def edit
    @notebook = Notebook.find(params[:id])
  end
  
  # POST /notebooks
  def create
    if params[:cancel_button]
      redirect_to notebooks_url, notice: "Notebook creation cancelled."
    else 
      @notebook = Notebook.create(notebook_params)
      if @notebook.save
        current_user.add_role(:owner, @notebook)
        current_user.save
        redirect_to notebook_url(@notebook), notice: "Notebook was successfully created."
      else
        flash[:error] = "Notebook creation failed: invalid input data."
        render :action => 'new'
      end
    end
  end
  
  # PATCH/PUT /notebooks/1
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
  
  # DELETE /notebooks/1
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

