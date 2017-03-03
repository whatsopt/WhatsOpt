class MultiDisciplinaryAnalysesController < ApplicationController
  before_action :set_multi_disciplinary_analysis, only: [:show, :edit, :update, :destroy]

  # GET /multi_disciplinary_analyses
  # GET /multi_disciplinary_analyses.json
  def index
    @multi_disciplinary_analyses = MultiDisciplinaryAnalysis.all
  end

  # GET /multi_disciplinary_analyses/1
  # GET /multi_disciplinary_analyses/1.json
  def show
  end

  # GET /multi_disciplinary_analyses/new
  def new
    @multi_disciplinary_analysis = MultiDisciplinaryAnalysis.new
  end

  # GET /multi_disciplinary_analyses/1/edit
  def edit
  end

  # POST /multi_disciplinary_analyses
  # POST /multi_disciplinary_analyses.json
  def create
    @multi_disciplinary_analysis = MultiDisciplinaryAnalysis.new(multi_disciplinary_analysis_params)

    respond_to do |format|
      if @multi_disciplinary_analysis.save
        format.html { redirect_to @multi_disciplinary_analysis, notice: 'Multi disciplinary analysis was successfully created.' }
        format.json { render :show, status: :created, location: @multi_disciplinary_analysis }
      else
        format.html { render :new }
        format.json { render json: @multi_disciplinary_analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /multi_disciplinary_analyses/1
  # PATCH/PUT /multi_disciplinary_analyses/1.json
  def update
    respond_to do |format|
      if @multi_disciplinary_analysis.update(multi_disciplinary_analysis_params)
        format.html { redirect_to @multi_disciplinary_analysis, notice: 'Multi disciplinary analysis was successfully updated.' }
        format.json { render :show, status: :ok, location: @multi_disciplinary_analysis }
      else
        format.html { render :edit }
        format.json { render json: @multi_disciplinary_analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /multi_disciplinary_analyses/1
  # DELETE /multi_disciplinary_analyses/1.json
  def destroy
    @multi_disciplinary_analysis.destroy
    respond_to do |format|
      format.html { redirect_to multi_disciplinary_analyses_url, notice: 'Multi disciplinary analysis was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_multi_disciplinary_analysis
      @multi_disciplinary_analysis = MultiDisciplinaryAnalysis.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def multi_disciplinary_analysis_params
      params.require(:multi_disciplinary_analysis).permit(:name)
    end
end
