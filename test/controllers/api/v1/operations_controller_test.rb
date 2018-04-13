require 'test_helper'

class Api::V1::OperationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
    @ope = operations(:doe)
  end
  
  test "should create an operation" do
    assert_difference('Operation.count') do
      post api_v1_mda_operations_url(@mda), 
    params: {operation: {name: 'doe', cases: {x1: [1, 2, 3], obj: [4, 5, 6]}}}, 
           as: :json, headers: @auth_headers
    end
    assert_response :success
  end

  test "should get an operation" do
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    assert_response :success
    p response.body
  end
    
end
