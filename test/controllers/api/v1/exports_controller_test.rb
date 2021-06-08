# frozen_string_literal: true

require "test_helper"

class Api::V1::ExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
  end

  test "should dump analysis as json" do
    get api_v1_mda_exports_new_url(@mda, format: :mdajson), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    expected = sample_file("cicav_mda.json").read.chomp
    assert_equal expected, resp.to_json.to_s
  end

  test "should dump nested analysis as json" do
    mda = analyses(:outermda)
    get api_v1_mda_exports_new_url(mda, format: :mdajson), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    expected = sample_file("outer_mda.json").read.chomp
    assert_equal expected, resp.to_json.to_s
  end

  test "should dump nested analysis as openmdao code" do
    mda = analyses(:outermda)
    get api_v1_mda_exports_new_url(mda, format: :openmdao), as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should dump nested analysis as gemseo code" do
    mda = analyses(:outermda)
    get api_v1_mda_exports_new_url(mda, format: :gemseo), as: :json, headers: @auth_headers
    assert_response :success
  end

end
