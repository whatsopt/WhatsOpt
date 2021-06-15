# frozen_string_literal: true

class Api::V1::AnalysesController < Api::ApiController
  before_action :set_mda, only: [:show, :update]

  # GET /api/v1/mdas
  def index
    @mdas = policy_scope(Analysis)
    if params[:all]
      @mdas
    elsif params[:design_project_query]  
      @mdas = @mdas.joins(design_project_filing: :design_project)
                   .where('design_projects.name like ?', '%' + params["design_project_query"] + '%')
    else
      @mdas = @mdas.with_role(:owner, current_user)
    end
    json_response @mdas, :ok, each_serializer: AnalysisItemSerializer
  end

  # GET /api/v1/mda/1
  def show
    if params[:format] == "whatsopt_ui"
      render json: @mda.to_whatsopt_ui_json
    elsif params[:format] == "xdsm"
      render json: @mda.to_xdsm_json
    else
      json_response @mda
    end
  end

  # POST /api/v1/mdas
  def create
    if params[:format] == "xdsm"
      skip_authorization
      xdsm = nil
      Analysis.transaction do
        xdsm = Rails.cache.fetch(mda_params.to_h.deep_sort!) do
          Rails.logger.info "CACHE MIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIISSSSSSSSSSSS"
          mda = create_nested_analysis
          mda.to_xdsm_json
        end
        raise ActiveRecord::Rollback
      end
      Rails.logger.debug ">>> XDSM = #{xdsm}"
      json_response xdsm, :ok
    else
      @mda = create_nested_analysis
      @mda.set_owner(current_user)
      authorize @mda
      json_response @mda, :created
    end
  end

  # PUT/PATCH /api/v1/mdas/1
  def update
    import = mda_params[:import]
    if import
      fromAnalysis = Analysis.find(import[:analysis])
      authorize(fromAnalysis, :show?)
      @mda.import!(fromAnalysis, import[:disciplines])
    else
      if mda_params[:design_project_id]
        @mda.update_design_project!(mda_params[:design_project_id])
      end
      @mda.update!(mda_params.except(:design_project_id))
    end
    head :no_content
  end

  protected
    def create_nested_analysis
      mda = Analysis.create_nested_analyses(mda_params)
      mda.save!
      mda
    end

    def set_mda
      @mda = Analysis.find(params[:id])
      authorize @mda
    end

    def mda_params
      params.require(:analysis).permit(
        :with_sub_analyses,
        :name,
        :note,
        :design_project_id,
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
