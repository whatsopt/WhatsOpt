# frozen_string_literal: true

class Api::V1::DisciplinesController < Api::ApiController
  before_action :set_discipline, only: [:show, :update, :destroy]
  after_action :save_journal, only: [:create, :update, :destroy]

  # GET /api/v1/disciplines/1
  def show
    json_response @discipline
  end

  # POST /api/v1/{mda_id}/disciplines
  def create
    mda = Analysis.find(params[:mda_id])
    authorize mda
    @discipline = mda.disciplines.create!(discipline_params)
    @journal = @discipline.analysis.init_journal(current_user)
    @journal.journalize(@discipline, Journal::ADD_ACTION)
    json_response @discipline, :created
  end

  # PATCH/PUT /api/v1/disciplines/1
  def update
    old_attrs = @discipline.attributes
    @discipline.update_discipline!(discipline_params)
    @journal.journalize_changes(@discipline, old_attrs)
    head :no_content
  rescue AnalysisDiscipline::AlreadyDefinedError => e
      json_response({ message: e.message }, :unprocessable_entity)
  end

  # DELETE /api/v1/disciplines/1
  def destroy
    # @discipline.destroy!
    @discipline.analysis.destroy_discipline!(@discipline)
    @journal.journalize(@discipline, Journal::REMOVE_ACTION)
    head :no_content
  end

  private
    def set_discipline
      @discipline = Discipline.find(params[:id])
      authorize @discipline
      @journal = @discipline.analysis.init_journal(current_user)
    end

    def discipline_params
      params.require(:discipline).permit(:name, :analysis_id, :type, :position, 
                                         endpoint_attributes: [:id, :host, :port, :_destroy],
                                         analysis_discipline_attributes: [:discipline_id, :analysis_id])
    end

    def save_journal
      @journal.save
    end
end
