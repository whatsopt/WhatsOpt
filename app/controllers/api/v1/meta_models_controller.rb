# frozen_string_literal: true

class Api::V1::MetaModelsController < Api::ApiController

  before_action :set_meta_model, only: [:show, :update, :destroy]

  def index
    @meta_models = policy_scope(MetaModel)
    render json: @meta_models, status: status, each_serializer: MetaModelItemSerializer
  end

  # GET /api/v1/meta_models/1
  def show
    render json: @meta_model, status: status, serializer: MetaModelSpecSerializer
  end

  # POST /api/v1/operations/{operation_id}/meta_models
  def create
    ope = Operation.find(params[:operation_id])
    mda = Analysis.build_metamodel_analysis(ope, meta_model_params[:variables])
    authorize mda
    if mda.save
      driver = MetaModel.get_driver_from_metamodel_kind(meta_model_params[:kind])
      name = MetaModel.get_name_from_metamodel_kind(meta_model_params[:kind])
      varnames = []
      unless meta_model_params[:variables].blank?
        varnames = meta_model_params[:variables][:inputs] + meta_model_params[:variables][:outputs]
      end
      # copy with prototype_variables (3rd arg) to attach cases to new variables in the new analysis mda
      mm_doe = ope.create_copy!(mda, varnames, Variable.of_analysis(mda))
      mm_ope = Operation.build_operation(mda, name: name, driver: driver)
      mm_ope.base_operation = mm_doe
      mm_ope.save!
      mda.set_all_parameters_as_decision_variables(ope.analysis.decision_role)
      mda.set_owner(current_user)

      @meta_model = mda.disciplines.last.build_meta_model( # just one plain discipline in the analysis
        operation: mm_ope,
        default_surrogate_kind: meta_model_params[:kind],
        default_options_attributes: meta_model_params[:options] || []
      )
      @meta_model.build_surrogates
      if @meta_model.save
        json_response @meta_model
      else
        Rails.logger.info @meta_model.errors
        json_response({ message: "Something went wrong. Can not create metamodel from current operation data." }, :bad_request)
      end
    else
      Rails.logger.info @mda.errors
      json_response({ message: "Something went wrong. Can not create metamodel from current operation data." }, :bad_request)
    end
  rescue MetaModel::BadKindError => err
    json_response({ message: "Bad metamodel kind: #{err.message}" }, :bad_request)
  end
  
  # PATCH /api/v1/meta_models/1
  def update
    format = meta_model_params[:format] || MetaModel::MATRIX_FORMAT  # format default to Matrix
    if format == MetaModel::MATRIX_FORMAT
      x = params[:meta_model][:x]
      responses = @meta_model.predict(x)  # strong params do not work on nested arrays
      json_response(y: responses)
    else
      json_response({ message: "Format not valid. Should be in #{MetaModel::FORMATS}, "\
                               "but found #{params[:meta_model][:format]}" }, :bad_request)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meta_model
      @meta_model = MetaModel.find(params[:id])
      authorize @meta_model
    end

    def meta_model_params
      params.require(:meta_model).permit(:kind, :format, 
                                         options: [ :name, :value ], 
                                         variables: [ inputs: [], outputs: [] ],
                                         x: [], 
                                        )
    end

end
