# frozen_string_literal: true

class Api::V1::AnalysesController < Api::ApiController
  before_action :set_mda, only: [:show, :update]

  # GET /api/v1/mdas
  def index
    @mdas = policy_scope(Analysis)
    json_response @mdas
  end

  # GET /api/v1/mda/1
  def show
    if params[:format] == "xdsm"
      render json: @mda.to_mda_viewer_json
    else
      json_response @mda
    end
  end

  # POST /api/v1/mdas
  def create
    @mda = Analysis.new(mda_params)
    authorize @mda
    @mda.save!
    @mda.set_owner(current_user)
    json_response @mda, :created
  end

  # PUT/PATCH /api/v1/mdas/1
  def update
    @mda.update(mda_params)
    head :no_content
  end

  protected
    def set_mda
      @mda = Analysis.find(params[:id])
      authorize @mda
    end

    def mda_params
      params.require(:analysis).permit(
        :name,
        :note,
        :public,
        disciplines_attributes:           [
            :name,
            variables_attributes: [
              :name, :io_mode, :type, :shape, :units, :desc,
              parameter_attributes: [:lower, :upper, :init],
              scaling_attributes: [:ref, :ref0, :res_ref]
            ],
            sub_analysis_attributes: {}
          ]
      )
    end
end
