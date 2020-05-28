# frozen_string_literal: true

class Api::V1::AnalysisDisciplinesController < Api::ApiController
  # POST /api/v1/analyses/:mda_id/analysis_discipline
  # POST /api/v1/disciplines/:discipline_id/analysis_discipline
  def create
    @innermda = Analysis.find(mda_discipline_params[:analysis_id])
    if params[:discipline_id]
      # create from a given discipline
      @disc = Discipline.find(params[:discipline_id])
      @outermda = @disc.analysis
    else
      # create from an analysis, build new discipline
      @outermda = Analysis.find(params[:mda_id])
      @disc = @outermda.disciplines.create(name: @innermda.name)
    end
    @mda_discipline = AnalysisDiscipline.build_analysis_discipline(@disc, @innermda)
    authorize @mda_discipline

    # finally save analysis discipline
    @mda_discipline.save!

    json_response @mda_discipline, :created
  end

  # DELETE /api/v1/disciplines/1/analysis_disciplines
  def destroy
    @mda_analysis = Discipline.find(params[:discipline_id]).analysis_discipline
    authorize @mda_analysis
    @mda_analysis.destroy!
    head :no_content
  end

  private
    def mda_discipline_params
      params.require(:analysis_discipline).permit(:analysis_id)
    end
end
