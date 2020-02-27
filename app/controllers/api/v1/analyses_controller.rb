# frozen_string_literal: true

class Api::V1::AnalysesController < Api::ApiController

  include Api::V1::Concerns::Docs::AnalysesController

  before_action :set_mda, only: [:show, :update]

  # GET /api/v1/mdas[?with_sub_analyses=true]
  def index
    if params[:with_sub_analyses]
      @mdas = Analysis.all
    else
      @mdas = Analysis.roots
    end
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
    import = mda_params[:import]
    if import
      fromAnalysis = Analysis.find(import[:analysis])
      authorize(fromAnalysis, :show?)
      @mda.import!(fromAnalysis, import[:disciplines])
    else
      @mda.update!(mda_params)
    end
    head :no_content
  end

  protected
    def set_mda
      @mda = Analysis.find(params[:id])
      authorize @mda
    end

    def mda_params
      params.require(:analysis).permit(
        :with_sub_analyses,
        :name,
        :note,
        :public,
        import: [:analysis, disciplines: [] ],
        disciplines_attributes: [
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
