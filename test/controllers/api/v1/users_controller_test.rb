require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:user1)
    @user2 = users(:user2)
    sign_in @user1
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
  end
  
  test "should update user analyses query setting" do
    put api_v1_user_url(@user1), params: {user: {settings: {analyses_query: 'all'}}}, 
        as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should not update if not authenticated" do
    put api_v1_user_url(@user2), params: {user: {settings: {analyses_query: 'all'}}}
    assert_response :unauthorized
  end
  
  test "should not update another user setting" do
    put api_v1_user_url(@user2), params: {user: {settings: {analyses_query: 'all'}}}, 
        as: :json, headers: @auth_headers
    assert_response :unauthorized
  end

end