class MultiDisciplinaryAnalysesController < ApplicationController
  before_action :set_mda, only: [:show, :edit, :update, :destroy]

  # GET /multi_disciplinary_analyses
  # GET /multi_disciplinary_analyses.json
  def index
    @mdas = MultiDisciplinaryAnalysis.all
  end

  # GET /multi_disciplinary_analyses/1
  # GET /multi_disciplinary_analyses/1.json
  def show
  end

  # GET /multi_disciplinary_analyses/new
  def new
    @mda = MultiDisciplinaryAnalysis.new
  end

  # GET /multi_disciplinary_analyses/1/edit
  def edit
  end

  # POST /multi_disciplinary_analyses
  # POST /multi_disciplinary_analyses.json
  def create
    @mda = MultiDisciplinaryAnalysis.new(mda_params)

    respond_to do |format|
      if @mda.save
        format.html { redirect_to @mda, notice: 'MDA was successfully created.' }
        format.json { render :show, status: :created, location: @mda }
      else
        format.html { render :new }
        format.json { render json: @mda.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /multi_disciplinary_analyses/1
  # PATCH/PUT /multi_disciplinary_analyses/1.json
  def update
    respond_to do |format|
      if @mda.update(mda_params)
        format.html { redirect_to @mda, notice: 'MDA was successfully updated.' }
        format.json { render :show, status: :ok, location: @mda }
      else
        format.html { render :edit }
        format.json { render json: @mda.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /multi_disciplinary_analyses/1
  # DELETE /multi_disciplinary_analyses/1.json
  def destroy
    @mda.destroy
    respond_to do |format|
      format.html { redirect_to multi_disciplinary_analyses_url, notice: 'MDA was successfully destroyed.' }
      format.json { head :no_content }
    end
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
