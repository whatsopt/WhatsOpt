# frozen_string_literal: true

require "test_helper"

class Api::V1::UserRolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
  end

  test "should search for members" do
    get api_v1_user_roles_url(query: { analysis_id: @mda.id, select: :members }), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    user3 = users(:user3)
    user4 = users(:user4)
    assert_equal [user3, user4].map { |u| { "id" => u.id, "login" => u.login } }, resp
  end

  test "should search for co_owners" do
    get api_v1_user_roles_url(query: { analysis_id: @mda.id, select: :co_owners }), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    user4 = users(:user4)
    assert_equal [{ "id" => user4.id, "login" => user4.login }], resp
  end

  test "should search for member candidates" do
    get api_v1_user_roles_url(query: { analysis_id: @mda.id, select: :member_candidates }), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    user2 = users(:user2)
    user5 = users(:user5)
    admin = users(:admin)
    assert_equal [admin.id, user5.id, user2.id], resp.map { |u| u["id"] }
  end

  test "should add a member" do
    user2 = users(:user2)
    assert_difference("UsersRole.count") do
      put api_v1_user_role_url(user2), params: { user_role: { analysis_id: @mda.id, role: :member } },
        as: :json, headers: @auth_headers
    end
  end

  test "should remove a member" do
    user3 = users(:user3)
    assert_difference("UsersRole.count", -1) do
      delete api_v1_user_role_url(user3), params: { user_role: { analysis_id: @mda.id, role: :member } },
        as: :json, headers: @auth_headers
    end
  end
end
