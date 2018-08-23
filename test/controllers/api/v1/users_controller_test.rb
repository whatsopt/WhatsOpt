require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
  end

  test "should search for members" do
    get api_v1_users_url(query: {analysis_id: @mda.id, select: :members}), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    user3 = users(:user3)
    assert_equal [{'id' => user3.id, 'login' => user3.login}], resp 
  end

  test "should search for member candidates" do
    get api_v1_users_url(query: {analysis_id: @mda.id, select: :member_candidates}), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    user2 = users(:user2)
    assert_equal [{'id' => user2.id, 'login' => user2.login}], resp 
  end
  
  test "should add a member" do
    user2 = users(:user2)
    assert_difference('UsersRole.count') do
      put api_v1_user_url(user2), params: {user: {analysis_id: @mda.id, role: :member}}, 
        as: :json, headers: @auth_headers
    end
  end
  
  test "should remove a member" do
    user3 = users(:user3)
    assert_difference('UsersRole.count', -1) do
      put api_v1_user_url(user3), params: {user: {analysis_id: @mda.id}}, 
        as: :json, headers: @auth_headers
    end
  end
end