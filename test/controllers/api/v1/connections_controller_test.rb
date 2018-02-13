require 'test_helper'

class Api::V1::ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
    @from = disciplines(:geometry)
    @to = disciplines(:aerodynamics)
    @var = variables(:varyg_geo_out)
  end
  
  test "should create a new connection" do
    post api_v1_mda_connections_url({mda_id: @mda.id, 
                                     connection: {from: @from.id, to: @to.id, names: ["newvar"]}}), 
         as: :json, headers: @auth_headers 
    assert_response :success
  end

  test "should fail to create connection if var name already exists" do
    post api_v1_mda_connections_url({mda_id: @mda.id, 
                                     connection: {from: @from.id, to: @to.id, names: [@var.name]}}), 
         as: :json, headers: @auth_headers 
    assert_match /Variable (\w+) already/, JSON.parse(response.body)["message"]
    assert_response :unprocessable_entity 
  end
  
  test "should raise error on bad request" do
    post api_v1_mda_connections_url({mda_id: @mda.id, 
                                     connection: {from: @from.id, to: @to.id, names: ['']}}), 
         as: :json, headers: @auth_headers 
    assert_match /can't be blank/, JSON.parse(response.body)["message"]
    assert_response :unprocessable_entity 
  end
      
  test "should delete a connection" do
    assert_difference('Variable.count', -2) do
      connyg = Connection.find_by_from_id(@var.id)
      delete api_v1_connection_url(connyg), as: :json, headers: @auth_headers
      assert_response :success
    end

  end

end
