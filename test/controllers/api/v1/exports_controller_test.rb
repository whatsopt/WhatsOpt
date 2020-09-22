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
  end
end
