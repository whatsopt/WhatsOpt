require 'test_helper'

class Api::V1::ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
    @from = disciplines(:geometry)
    @to = disciplines(:aerodynamics)
    @varyg = variables(:varyg_geo_out)
    @conn = connections(:geo_aero)
    @varzout = variables(:varz_design_out)
  end
  
  test "should create a new connection" do
    post api_v1_mda_connections_url({mda_id: @mda.id, 
                                     connection: {from: @from.id, to: @to.id, names: ["newvar"]}}), 
         as: :json, headers: @auth_headers 
    assert_response :success
    conn = Connection.last
    assert_equal WhatsOpt::Variable::STATE_VAR_ROLE, conn.role
  end

  test "should create no new variable if connection already exists" do
    assert_difference('Connection.count', 0) do
      post api_v1_mda_connections_url({mda_id: @mda.id, 
                                       connection: {from: @from.id, to: @to.id, names: [@varyg.name]}}), 
           as: :json, headers: @auth_headers 
      assert_response :success
    end
  end
  
  test "should create connection from same discipline to other ones" do
    post api_v1_mda_connections_url({mda_id: @mda.id, 
                                     connection: {from: @from.id, to: @mda.driver.id, names: [@varyg.name]}}), 
         as: :json, headers: @auth_headers 
    assert_response :success
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
      connyg = Connection.find_by_from_id(@varyg.id)
      delete api_v1_connection_url(connyg), as: :json, headers: @auth_headers
      assert_response :success
    end
  end

  test "should delete a connection but keep out variable if there is another connection" do
    connz = Connection.where(from_id: @varzout.id)
    assert_equal 2, connz.count
    connz1 = connz.first
    connz2 = connz.second
    assert_difference('Variable.count', -1) do
      delete api_v1_connection_url(connz1), as: :json, headers: @auth_headers
      assert_response :success
    end
  end
  
  test "should update a connection" do
    attrs = [:name, :type, :shape, :units, :desc, :active]
    values = ['test', 'Integer', '(1, 2)', 'm', 'test description', false]
    update_attrs = attrs.zip(values).to_h
    update_attrs[:parameter_attributes] = {init: "[[1,2]]", lower: "0", upper:"10"}
    refute @conn.from.parameter
    put api_v1_connection_url(@conn, {connection: update_attrs}), as: :json, headers: @auth_headers
    assert_response :success
    @conn.reload
    attrs.each_with_index do |attr, i|
      assert_equal values[i], @conn.from.send(attr)
      assert_equal values[i], @conn.to.send(attr)
    end
    assert @conn.from.parameter
    assert_equal "[[1,2]]", @conn.from.parameter.init
    assert_equal "0", @conn.from.parameter.lower
    assert_equal "10", @conn.from.parameter.upper
    refute @conn.to.parameter
    refute @conn.to.active
    refute @conn.from.active
  end  

end
