# frozen_string_literal: true

class Api::V1::VariablesController < Api::V1::ApiMdaUpdaterController

  # GET /api/v1/analyses/{mda_id}/variables
  def index
    @mda = Analysis.find(params[:mda_id])
    authorize @mda, :show?
    variables = policy_scope(Variable).of_analysis(@mda).where(io_mode: WhatsOpt::Variable::OUT)
    json_response variables
  end

end
