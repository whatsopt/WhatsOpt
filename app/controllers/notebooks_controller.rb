class NotebooksController < ApplicationController
  before_action :set_notebook, only: [:show, :edit, :update, :destroy]
    
  # GET /notebooks
  def index
    @notebooks = policy_scope(Notebook)
  end
  
  # GET /notebooks/1
  def show
  end

  # GET /notebooks/new
  def new
    @notebook = Notebook.new
    authorize @notebook
  end
  
  # GET /notebooks/1/edit
  def edit
  end
  
  # POST /notebooks
  def create
    if params[:cancel_button]
      redirect_to notebooks_url, notice: "Notebook import cancelled."
    else 
      @notebook = Notebook.new(notebook_params)
      authorize @notebook
      if @notebook.save
        current_user.add_role(:owner, @notebook)
        current_user.save
        redirect_to notebook_url(@notebook), notice: "Notebook was successfully imported."
      else
        flash[:error] = "Notebook import failed: invalid input data."
        render :action => 'new'
      end
    end
  end
  
  # PATCH/PUT /notebooks/1
  def update
    if params[:cancel_button]
      redirect_to notebooks_url, notice: "Notebook update cancelled."
    else   
      authorize @notebook
      if @notebook.update(notebook_params)
        flash[:notice] = "Successfully updated notebook."
        redirect_to notebook_url
      else
        render :action => 'edit'
      end
    end
  end
  
  # DELETE /notebooks/1
  def destroy
    @notebook.destroy
    flash[:notice] = "Successfully deleted notebook."
    redirect_to notebooks_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_notebook
    @notebook = Notebook.find(params[:id])
    authorize @notebook
  end
  
  def notebook_params
    params.fetch(:notebook, {}).permit(:title, :attachment_attributes => [:id, :data, :_destroy])   
  end
    
end

