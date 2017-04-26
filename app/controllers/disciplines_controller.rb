class DisciplinesController < ApplicationController
  before_action :set_discipline, only: [:show, :edit, :update, :destroy]

  # GET /disciplines
  def index
    @disciplines = Discipline.all
  end

  # GET /disciplines/1
  def show
  end

  # GET /disciplines/new
  def new
    @discipline = Discipline.new
  end

  # GET /disciplines/1/edit
  def edit
  end

  # POST /disciplines
  def create
    @discipline = Discipline.new(discipline_params)
    if @discipline.save
      redirect_to @discipline, notice: 'Discipline was successfully created.' 
    else
      render :new 
    end
  end

  # PATCH/PUT /disciplines/1
  def update
    if @discipline.update(discipline_params)
      format.html { redirect_to @discipline, notice: 'Discipline was successfully updated.' }
    else
      render :edit
    end
  end

  # DELETE /disciplines/1
  def destroy
    @discipline.destroy
    redirect_to disciplines_url, notice: 'Discipline was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_discipline
      @discipline = Discipline.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def discipline_params
      params.require(:discipline).permit(:name, :multi_disciplinary_analisys_id)
    end
end
