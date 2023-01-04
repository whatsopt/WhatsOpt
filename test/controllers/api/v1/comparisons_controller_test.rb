# frozen_string_literal: true

require "test_helper"

class Api::V1::ComparisonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
    @mda_copy = @mda.create_copy!
    @mda_copy.reload
  end

  test "should compare two analyses" do
    get api_v1_mda_comparisons_new_url(@mda, with: @mda_copy), as: :json, headers: @auth_headers
    assert_response :success
    resp = response.body
    refute resp.empty?  # should get a diff as the copy set designvars back to parameters
  end

end
