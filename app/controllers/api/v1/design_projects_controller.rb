# frozen_string_literal: true

class Api::V1::DesignProjectsController < Api::ApiController
  # GET /api/v1/design_projects
  def index
    json_response policy_scope(DesignProject)
  end

  # POST /api/v1/design_projects
  def create
    @project = DesignProject.create!(project_params.except(:analyses_attributes))
    project_params["analyses_attributes"].each do |mda_params|
      mda = Analysis.create_nested_analyses(mda_params)
      mda.save!
      mda.set_owner(current_user)
      journal = mda.init_journal(current_user)
      journal.journalize(mda, Journal::ADD_ACTION)
      journal.save!
      @project.analyses << mda
    end
    @project.set_owner(current_user)
    authorize @project
    @project.save!
    json_response @project, :created
  end

  # GET /api/v1/design_projects/1
  def show
    @project = DesignProject.find(params[:id])
    if params[:format]  == "wopjson"  # wop pull --json
      authorize @project, :destroy?   # only owner can export a project
      json_response @project, :ok, serializer: DesignProjectAttrsSerializer
    else # Design project public REST API
      authorize @project
      json_response @project
    end
  end

private

  def project_params
    params.require(:project).permit(
      :name,
      :description,
      analyses_attributes: [:name,
                            :note,
                            :public,
                            disciplines_attributes: [
                              :name,
                              variables_attributes: [
                                :name, :io_mode, :type, :shape, :units, :desc,
                                parameter_attributes: [:lower, :upper, :init],
                                scaling_attributes: [:ref, :ref0, :res_ref]
                              ],
                              sub_analysis_attributes: {}
                            ]]) 
  end

end
