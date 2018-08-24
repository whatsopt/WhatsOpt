class Api::V1::UsersController < Api::ApiController

  # GET /api/v1/users
  def index
    if params[:query]
      mda = Analysis.find(params[:query][:analysis_id])
      case params[:query][:select]
      when "members"
        json_response policy_scope(User).with_any_role({ :name => :member, :resource => mda })
      when "member_candidates"
        allUsers = policy_scope(User).all 
        authorizedUsers = User.with_role(:admin)
        authorizedUsers += User.with_role_for_instance(:owner, mda)
        authorizedUsers += User.with_role_for_instance(:member, mda)
        users = allUsers - authorizedUsers
        json_response users 
      else
        json_response({ message: 'Bad query: should select "members" or "member_candidates' }, :unprocessable_entity)
      end
    else
      json_response policy_scope(User)
    end
  end
  
  # PUT/PATCH /api/v1/users/1
  def update
    user = User.find(params[:id])
    mda = Analysis.find(params[:user][:analysis_id])
    authorize mda
    if params[:user][:role] == "member"
      user.add_role :member, mda
    else 
      user.remove_role :member, mda
    end
    head :no_content
  end
  
end