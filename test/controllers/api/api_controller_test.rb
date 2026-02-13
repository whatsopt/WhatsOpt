# frozen_string_literal: true

require "test_helper"

class Api::V1::VersioningsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "should respond forbidden when wop version mismatch" do
    get api_v1_versioning_url, as: :json, headers: @auth_headers.merge!("User-Agent" => "wop/1.0.0")
    assert_response :forbidden
  end

  test "should respond not_found when getting an unknown resource" do
    get api_v1_operation_url(666), as: :json, headers: @auth_headers
    assert_response :not_found
  end
end
