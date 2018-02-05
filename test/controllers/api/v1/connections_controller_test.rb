require 'test_helper'

class Api::V1::ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
    @from = @mda.disciplines.nodes.first
    @to = @mda.disciplines.nodes.second
    @var = @to.variables.take
  end
  
  test "should create a new connection" do
    post api_v1_mda_connections_url({mda_id: @mda.id, 
                                     connection: {from: @from.id, to: @to.id, name: "newvar"}}), 
         as: :json, headers: @auth_headers 
    assert_response :success
  end

  test "should fail to create connection if var name already exists" do
    post api_v1_mda_connections_url({mda_id: @mda.id, 
                                     connection: {from: @from.id, to: @to.id, name: @var.name}}), 
         as: :json, headers: @auth_headers 
    assert_match /Variable x already in use/, JSON.parse(response.body)["message"]
    assert_response :unprocessable_entity 
  end

    
end
