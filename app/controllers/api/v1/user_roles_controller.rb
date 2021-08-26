# frozen_string_literal: true

class Api::V1::UserRolesController < Api::ApiController
  # GET /api/v1/users
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
        json_response({ message: 'Bad query: should select "members", "co_owners", "member_candidates" or "co_owner_candidates"'  }, :unprocessable_entity)
      end
    else
      json_response policy_scope(User)
    end
  end

  # PUT/PATCH /api/v1/users/1
  def update
    user = User.find(params[:id])
    mda = Analysis.find(params[:user][:analysis_id])
    authorize mda, :destroy?
    if params[:user][:role]
      if params[:user][:role] == "member"
        mda.add_member user
      else
        mda.remove_member user
      end
    end
    head :no_content
  end
end
