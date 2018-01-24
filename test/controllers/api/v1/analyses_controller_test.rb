require 'test_helper'

class Api::V1::AnalysesControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
    @mda2 = analyses(:fast)
    @disc = @mda.disciplines.nodes.first
  end
  
  test "should get mdas" do
    get api_v1_mdas_url, as: :json, headers: @auth_headers
    assert_response :success
  end
  
  test "should create a mda" do
    post api_v1_mdas_url, params: { analysis: { name: "TestMda" } }, as: :json, headers: @auth_headers
    assert_response :success
  end
  
  test "should update a mda" do
    put api_v1_mda_url(@mda), params: { analysis: { name: "TestNewName" } }, as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_mda_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 'TestNewName', resp['name'] 
  end  
  
  test "should update a mda with attachment" do
    @mda.build_attachment()
    @mda.attachment.data = sample_file("excel_mda_simple_sample.xlsx")
    @mda.save!
    put api_v1_mda_url(@mda), params: { analysis: { name: "TestNewName" } }, as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_mda_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 'TestNewName', resp['name'] 
  end  

end
