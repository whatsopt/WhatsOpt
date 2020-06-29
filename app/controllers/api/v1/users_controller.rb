# frozen_string_literal: true

class Api::V1::UsersController < Api::ApiController
  # PUT/PATCH /api/v1/users/1
  def update
    @user = User.find(params[:id])
    authorize @user
    if params[:user][:settings]
      current_user.update(settings: @user.settings.merge(user_params[:settings]))
    end
    head :no_content
  end

  def user_params
    params.require(:user).permit(settings: [:analyses_query, :analyses_scope_design_project_id])
  end
end
