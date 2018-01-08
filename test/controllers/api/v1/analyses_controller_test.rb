require 'test_helper'

class Api::V1::AnalysesControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
    @disc = @mda.disciplines.analyses.first
  end
  
  test "should create an mda" do
    post api_v1_mdas_url(@mda), params: { analysis: { name: "TestMda" } }, as: :json, headers: @auth_headers
    assert_response :success
  end
  
end
