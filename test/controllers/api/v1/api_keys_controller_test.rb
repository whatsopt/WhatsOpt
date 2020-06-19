# frozen_string_literal: true

require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:user1)
    sign_in @user1
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "should reset api key" do
    put api_v1_user_api_key_url(@user1), as: :json, headers: @auth_headers
    assert_response :success
    put api_v1_user_api_key_url(@user1), as: :json, headers: @auth_headers
    assert_response :unauthorized
    @auth_headers = { "Authorization" => "Token " + @user1.reload.api_key }
    put api_v1_user_api_key_url(@user1), as: :json, headers: @auth_headers
    assert_response :success
  end
end
