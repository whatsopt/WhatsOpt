# frozen_string_literal: true

class Api::V1::DisciplinesController < Api::V1::ApiMdaUpdaterController
  before_action :set_discipline, only: [:show, :update, :destroy]
  before_action :check_mda_update, only: [:update, :destroy]

  after_action :save_journal, only: [:create, :update, :destroy]

  # GET /api/v1/disciplines/1
  def show
    json_response @discipline
  end

  # POST /api/v1/{mda_id}/disciplines
  def create
    @mda = Analysis.find(params[:mda_id])
    check_mda_update
    authorize @mda, :update?
    @discipline = @mda.disciplines.create!(discipline_params)
    @journal = @mda.init_journal(current_user)
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
    @mda.destroy_discipline!(@discipline)
    @journal.journalize(@discipline, Journal::REMOVE_ACTION)
    head :no_content
  end

  private
    def set_discipline
      @discipline = Discipline.find(params[:id])
      @mda = @discipline.analysis
      authorize @mda, :update?
      @journal = @mda.init_journal(current_user)
    rescue ActiveRecord::RecordNotFound => e  # likely to occur on concurrent update
      begin
        @mda = Analysis.find(params[:mda_id])
        authorize @mda, :update?
        check_mda_update   # raise StaleObjectError
        raise e            # otherwise re-raise
      rescue ActiveRecord::RecordNotFound => e1
        raise e
      end
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
