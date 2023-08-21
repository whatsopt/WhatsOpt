# frozen_string_literal: true

class Api::V1::UserRolesController < Api::ApiController
  # GET /api/v1/user_roles
  def index
    if params[:query]
      mda = Analysis.find(params[:query][:analysis_id])
      case params[:query][:select]
      when "members"
        json_response policy_scope(User).with_any_role(name: :member, resource: mda)
      when "co_owners"
        json_response policy_scope(User).with_any_role(name: :co_owner, resource: mda)
      when "member_candidates"
        allUsers = policy_scope(User).all
        readers = mda.readers
        users = allUsers - readers
        json_response users
      when "co_owner_candidates"
        allUsers = policy_scope(User).all
        updaters = mda.updaters
        users = allUsers - updaters
        json_response users
      else
        skip_authorization
        json_response({ message: 'Bad query: should select "members", "co_owners", "member_candidates" or "co_owner_candidates"'  }, :unprocessable_entity)
      end
    else
      json_response policy_scope(User)
    end
  end

  # PUT/PATCH /api/v1/user_roles/1
  def update
    user = User.find(params[:id])
    mda = Analysis.find(params[:user_role][:analysis_id])
    authorize mda, :destroy?
    if params[:user_role][:role]
      if params[:user_role][:role] == "member"
        mda.add_member user
      elsif params[:user_role][:role] == "co_owner"
        mda.add_co_owner user
      end
    end
    head :no_content
  end

  # DELETE /api/v1/user_roles/1
  def destroy
    user = User.find(params[:id])
    mda = Analysis.find(params[:user_role][:analysis_id])
    authorize mda, :destroy?
    if params[:user_role][:role]
      if params[:user_role][:role] == "member"
        mda.remove_member user
      elsif params[:user_role][:role] == "co_owner"
        mda.remove_co_owner user
      end
    end
    head :no_content
  end
end
