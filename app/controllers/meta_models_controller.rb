# frozen_string_literal: true

class MetaModelsController < ApplicationController
  # POST /operations/{operation_id}/meta_models
  def create
    ope = Operation.find(params[:operation_id])
    mda = Analysis.build_metamodel_analysis(ope, meta_model_params[:variables])
    authorize mda
    if mda.save
      driver = get_driver_from_metamodel_kind(meta_model_params[:kind])
      vars = []
      unless meta_model_params[:variables].blank?
        vars = meta_model_params[:variables][:inputs] + meta_model_params[:variables][:outputs]
      end
      mm_doe = ope.build_copy(mda, vars)
      mm_ope = Operation.build_operation(mda, name: "metamodel", driver: driver)
      mm_ope.base_operation = mm_doe
      mm_ope.save!
      mda.set_all_parameters_as_design_variables
      mda.set_owner(current_user)
      @meta_model = mda.disciplines.last.build_meta_model( # just one plain discipline in the analysis
        operation: mm_ope,
        default_surrogate_kind: meta_model_params[:kind])
      @meta_model.build_surrogates
      if @meta_model.save
        redirect_to mda_url(mda), notice: "Metamodel was successfully created."
      else
        redirect_to operation_url(ope), notice: "Something went wrong. Can not create metamodel from current operation data."
      end
    else
      redirect_to operation_url(ope), notice: "Something went wrong. Can not create analysis from current operation data."
    end
  end

  private
    def meta_model_params
      params.require(:meta_model).permit(:kind, variables: { inputs: [], outputs: [] })
    end

    def get_driver_from_metamodel_kind(kind)
      kind = kind.downcase
      kind =~ /(\w+)_(\w+)/
      library, algo = $1, $2
      "#{library}_metamodel_#{algo}"
    end
end
