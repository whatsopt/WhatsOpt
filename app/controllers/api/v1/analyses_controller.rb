# frozen_string_literal: true

class Api::V1::AnalysesController < Api::V1::ApiMdaUpdaterController
  before_action :set_mda, only: [:show, :update]
  before_action :check_mda_update, only: [:update]

  after_action :save_journal, only: [:create, :update]

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
    if params[:format] == "whatsopt_ui"  # WhatsOpt App
      render json: @mda.to_whatsopt_ui_json
    elsif params[:format] == "xdsm"      # wop show
      render json: @mda.to_xdsm_json
    elsif params[:format] == "wopjson"  # wop pull --json
      json_response @mda, :ok, serializer: AnalysisAttrsSerializer
    else # Analysis public REST API
      json_response @mda
    end
  end

  # POST /api/v1/mdas
  def create
    if params[:format] == "xdsm"  # wop show <openmdao_pb.py>
      skip_authorization
      xdsm = nil
      original_connection = Analysis.remove_connection
      begin
        ActiveRecord::Base.connected_to(role: :writing, shard: :scratch) do
          Analysis.transaction do
            xdsm = Rails.cache.fetch(mda_params.to_h.deep_sort!) do
              Rails.logger.debug ">>> XDSM request cache miss"
              Rails.logger.debug ">>> XDSM creation..."
              mda = create_nested_analysis
              mda.init_journal(current_user)
              Rails.logger.debug ">>> XDSM depth=#{mda.depth}"
              mda.to_xdsm_json
            end
            raise ActiveRecord::Rollback  # no need to keep saved analyses in scratch database
          end
        end
      end
      json_response xdsm, :ok
    else # wop push
      @mda = create_nested_analysis
      @mda.set_owner(current_user)
      authorize @mda
      @journal = @mda.init_journal(current_user)
      @journal.journalize(@mda, Journal::ADD_ACTION)
      json_response @mda, :created
    end
  end

  # PUT/PATCH /api/v1/mdas/1
  def update
    import = mda_params[:import]   # import/export disicplines
    if @mda.locked && mda_params.has_key?(:locked)
      old_attrs = @mda.get_jounalized_attrs
      @mda.update!(mda_params)
      @journal.journalize_changes(@mda, old_attrs)
      json_response @mda
    elsif import
      if @mda.packaged? || @mda.operated?
        p @mda.packaged?
        p @mda.operated?
        json_response @mda, :forbidden
      else
        fromAnalysis = Analysis.find(import[:analysis])
        authorize(fromAnalysis, :show?)
        new_discs = @mda.import!(fromAnalysis, import[:disciplines])
        new_discs.filter { |d| d.has_sub_analysis? }.each do |disc|
          disc.sub_analysis.set_owner(current_user)
          disc.sub_analysis.copy_ownership(@mda)
        end
        info = new_discs.map { |d| d.name }.join(", ")
        what_info = "[#{info}]"
        @journal.journalize(fromAnalysis, Journal::COPY_ACTION, copy_what: what_info)
        json_response @mda
      end
    else  # update analysis proper attributes
      old_attrs = @mda.get_jounalized_attrs
      if mda_params[:design_project_id]
        @mda.update_design_project!(mda_params[:design_project_id])
      end
      @mda.update!(mda_params.except(:design_project_id))
      @journal.journalize_changes(@mda, old_attrs)
      json_response @mda
    end
  rescue Connection::VariableAlreadyProducedError => e
    json_response({ message: e }, :unprocessable_entity)
  end

  protected
    def create_nested_analysis
      mda = Analysis.create_nested_analyses(mda_params)
      mda.save!
      mda
    end

    def set_mda
      @mda = Analysis.find(params[:id])
      if @mda.locked && mda_params.has_key?(:locked)
        authorize @mda, :unlock?
      else
        authorize @mda
      end
      @journal = @mda.init_journal(current_user)
    end

    def save_journal
      @mda&.save_journal  # optional when requesting xdsm
    end

    def mda_params
      params.require(:analysis).permit(
        :name,
        :note,
        :design_project_id,
        :public,
        :locked,
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
