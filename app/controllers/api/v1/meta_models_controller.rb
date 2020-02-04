# frozen_string_literal: true

class Api::V1::MetaModelsController < Api::ApiController

  include Api::V1::Concerns::Docs::MetaModelsController

  before_action :set_meta_model, only: [:show, :update, :destroy]

  # GET /api/v1/meta_models/1
  def show
    json_response @meta_model
  end

  # POST /api/v1/operations/{operation_id}/meta_models
  def create
    ope = Operation.find(params[:operation_id])
    mda = Analysis.build_metamodel_analysis(ope, meta_model_params[:variables])
    authorize mda
    if mda.save
      driver = MetaModel.get_driver_from_metamodel_kind(meta_model_params[:kind])
      name = MetaModel.get_name_from_metamodel_kind(meta_model_params[:kind])
      vars = []
      unless meta_model_params[:variables].blank?
        vars = meta_model_params[:variables][:inputs] + meta_model_params[:variables][:outputs]
      end
      mm_doe = ope.create_copy!(mda, vars)
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
        json_response({ message: "Something went wrong. Can not create metamodel from current operation data." }, :bad_request)
      end
    else
      json_response({ message: "Something went wrong. Can not create metamodel from current operation data." }, :bad_request)
    end
  rescue MetaModel::BadKindError => err
    json_response({ message: "Bad metamodel kind: #{err.message}" }, :bad_request)
  end
  
  # PATCH /api/v1/meta_models/1
  def update
    if params[:meta_model][:format] == MetaModel::MATRIX_FORMAT
      responses = @meta_model.predict params[:meta_model][:values]  # strong params do not work on nested arrays
      json_response(responses: responses)
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
                                         values: [], 
                                        )
    end

    # def _get_options(opt_params)
    #   opt_params.map {|o| {name: o[:name], value: o[:value]}}
    # end
end
