# frozen_string_literal: true

class Api::V1::ApiKeysController < Api::ApiController

  # PUT/PATCH /api/v1/users/1/api_key
  def update
    @user = User.find(params[:user_id])
    authorize @user
    @user.reset_api_key!
    head :no_content
  end

end
