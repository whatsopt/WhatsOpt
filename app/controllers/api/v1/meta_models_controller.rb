# frozen_string_literal: true

class Api::V1::MetaModelsController < Api::ApiController
  before_action :set_meta_model, only: [:show, :update, :destroy]

  # GET /api/v1/meta_models/1
  def show
    json_response @meta_model
  end

  # POST /api/v1/{operation_id}/meta_models
  def create
    if params[:operation_id]
      ope = Operation.find(params[:operation_id])
      authorize ope
      mda = Analysis.build_metamodel_analysis(ope)
      mda.save!
      mda.set_all_parameters_as_design_variables
      mda.set_owner(current_user)
      @meta_model = mda.build_meta_model(operation: ope)
      @meta_model.build_surrogates
      @meta_model.save!
    end
  end

  # PATCH /api/v1/meta_models/1
  def update
    if (metamodel_params[:format] == MetaModel::MATRIX_FORMAT)
      responses = @meta_model.predict params[:meta_model][:values]  # strong params do not work on nested arrays
      json_response({ responses: responses })
    else
      json_response({ message: "Format not valid. Should be in #{MetaModel::FORMATS}, "\
                               "but found #{metamodel_params[:format]}" }, :bad_request)
    end
  end

  # DELETE /api/v1/meta_models/1
  def destroy

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meta_model
      @meta_model = MetaModel.find(params[:id])
      authorize @meta_model
    end

    def metamodel_params
      params.require(:meta_model).permit(:format, {:values => {}})
    end
end
