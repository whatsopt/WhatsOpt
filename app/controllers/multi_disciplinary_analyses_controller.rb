class MultiDisciplinaryAnalysesController < ApplicationController
  before_action :set_mda, only: [:show, :edit, :update, :destroy]

  # GET /multi_disciplinary_analyses
  def index
    @mdas = MultiDisciplinaryAnalysis.all
  end

  # GET /multi_disciplinary_analyses/1
  def show
  end

  # GET /multi_disciplinary_analyses/new
  def new
    @import = !!params[:import]
    @mda = MultiDisciplinaryAnalysis.new
  end

  # GET /multi_disciplinary_analyses/1/edit
  def edit
  end

  # POST /multi_disciplinary_analyses
  def create
    if params[:cancel_button]
      redirect_to multi_disciplinary_analyses_url, notice: "MDA creation cancelled."
    else 
      if @mda.save
        redirect_to @mda, notice: 'MDA was successfully created.'
      else
        render :new
      end
    end
  end

  # PATCH/PUT /multi_disciplinary_analyses/1
  def update
    if @mda.update(mda_params)
      redirect_to @mda, notice: 'MDA was successfully updated.' 
    else
      render :edit 
    end
  end

  # DELETE /multi_disciplinary_analyses/1
  def destroy
    @mda.destroy
    redirect_to multi_disciplinary_analyses_url, notice: 'MDA was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mda
      @mda = MultiDisciplinaryAnalysis.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mda_params
      params.require(:multi_disciplinary_analysis).permit(:name)
    end
end
