# frozen_string_literal: true

class Api::V1::DesignProjectFilingsController < Api::ApiController

  before_action :set_mda

  # POST /api/v1/analysis/{mda_id}/design_project_filing
  def create
    @project = Analysis.find(filing_params[:design_project_id])
    @filing = DesignProjectFiling.new(analysis: @mda, design_project: project)
    @filing.save!
    json_response @filing, :created
  end

  # DELETE /api/v1/analysis/{mda_id}/design_project_filing
  def destroy
    @mda.design_project_filing.destroy!
    head :no_content
  end

private 

  def set_mda
    @mda = Analysis.find(params[:mda_id])
    authorize @mda
  end

  def filing_params
    params.require(:design_project_filing).permit(:design_project_id)
  end

end
