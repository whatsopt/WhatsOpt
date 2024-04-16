# frozen_string_literal: true

require "test_helper"

class Api::V1::VariableControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @user1 = users(:user1)
    @mda = analyses(:outermda)
  end

  test "should get variables" do
    get api_v1_mda_variables_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal ["x1", "x2", "y", "y1", "y2", "z"], resp.map { |v| v["name"] }.sort
    assert_equal ["Float", "Float", "Float", "Float", "Float", "Float"], resp.map { |v| v["type"] }.sort
  end

end
