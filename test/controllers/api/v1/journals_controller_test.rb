# frozen_string_literal: true

require "test_helper"

class Api::V1::JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "should get an empty journal" do
    @mda = analyses(:cicav)
    get api_v1_mda_journal_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal [], resp
  end

  test "should get a journal" do
    @mda = analyses(:singleton)
    get api_v1_mda_journal_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 1, resp.size
  end
end
