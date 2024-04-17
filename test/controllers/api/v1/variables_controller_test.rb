# frozen_string_literal: true

require "test_helper"

class Api::V1::VariableControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @user1 = users(:user1)
    @mda = analyses(:outermda)
    @varz = variables(:varz_outermda_driver_out)
  end

  test "should get variables" do
    get api_v1_mda_variables_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal ["x1", "x2", "y", "y1", "y2", "z"], resp.map { |v| v["name"] }.sort
  end

  test "should get info on a given variable" do
    get api_v1_mda_variable_url(@mda, @varz), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal WhatsOpt::Discipline::NULL_DRIVER_NAME, resp["from"][0]["name"]
    assert_equal "PlainDiscipline", resp["to"][0][0]["name"]
    assert_equal "INNER", resp["to"][0][1][0]["name"]
    assert_equal "Disc", resp["to"][1][0]["name"]
    assert_equal [], resp["to"][1][1]
  end

end
