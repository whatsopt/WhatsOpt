require 'test_helper'

class Api::V1::OperationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
    @ope = operations(:doe)
  end
  
  test "should create an operation" do
    assert_difference('Operation.count', 1) do
      post api_v1_mda_operations_url(@mda), 
        params: {operation: {name: 'new_doe', cases: [{varname: 'x1', coord_index: 0, values: [10, 20, 30]}, 
                                              {varname: 'obj', coord_index: 0, values: [40, 50, 60]}]}}, 
          as: :json, headers: @auth_headers
    end
    assert_response :success
    @mda.reload
    get api_v1_operation_url(@mda.operations.last), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 'new_doe', resp['name']
    assert_equal 'runonce', resp['driver']
    assert_equal 2, resp['cases'].length 
    assert_equal ['obj', 'x1'], resp['cases'].map{|c| c['varname']}.sort 
    assert_equal [0, 0], resp['cases'].map{|c| c['coord_index']}.sort
    assert_equal [10, 20, 30, 40, 50, 60], resp['cases'].map{|c| c['values']}.flatten.sort
    assert_equal({'status'=> 'DONE', 'log'=> ''}, resp['job'])
  end

  test "should create an operation with LHS options" do
    assert_difference('Operation.count', 1) do
      post api_v1_mda_operations_url(@mda), 
        params: {operation: {name: 'new_doe', host:'localhost', driver:'lhs', 
                             options_attributes: [{name: 'lhs_nbpts', value:'57'}]}}, 
        as: :json, headers: @auth_headers
    end
    assert_response :success
    opt = Operation.last.options.first
    assert_equal 'lhs_nbpts', opt.name
    assert_equal '57', opt.value
  end
  
  test "should get an operation" do
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should update an operation with cases" do
    patch api_v1_operation_url(@ope), 
      params: {operation: {name: 'update_doe', driver: 'slsqp', cases: [{varname: 'x1', coord_index: 0, values: [4, 5, 6]},
                                                                        {varname: 'y2', coord_index: 0, values: [1, 2, 3]}]}},
      as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    resp = JSON.parse(response.body)
    assert_equal 'update_doe', resp['name']
    assert_equal 'slsqp', resp['driver']
    assert_equal ['x1', 'y2'], resp['cases'].map{|c| c['varname']}.sort 
    assert_equal [0, 0], resp['cases'].map{|c| c['coord_index']}.sort
    assert_equal [1, 2, 3, 4, 5, 6], resp['cases'].map{|c| c['values']}.flatten.sort
    assert_equal 'DONE', resp['job']['status']
    assert_equal 'this is a test job\\nData uploaded\\n', resp['job']['log']
  end

  test "should update an operation with LHS options" do
    patch api_v1_operation_url(@ope), 
    params: {operation: {name: 'update_doe', driver: 'lhs', 
                         cases: [],
                         options_attributes: [{id: @ope.options.first.id, name: 'lhs_nbpts', value:20}]}},
      as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    resp = JSON.parse(response.body)
    assert_equal [{"id" => @ope.options.first.id, "name" => 'lhs_nbpts', "value" => '20'}], resp['options']
  end
  
  test "should update an operation with SLSQP options" do
    prev_options_to_destroy = @ope.options.map{|opt| {id: opt.id, _destroy: 1}}
    new_options = prev_options_to_destroy + [{name: 'slsqp_tol', value:1e-6},
                                             {name: 'slsqp_disp', value:false},
                                             {name: 'slsqp_maxiter', value:10}]
    patch api_v1_operation_url(@ope), 
    params: {operation: {name: 'update_optim', driver: 'slsqp', 
                         cases: [],
                         options_attributes: new_options }},
      as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    resp = JSON.parse(response.body)
    @ope.reload
    assert_equal 3, @ope.options.length
    assert_equal [{"id" => @ope.options[0].id, "name" => 'slsqp_tol', "value" => '1.0e-06'},
                  {"id" => @ope.options[1].id, "name" => 'slsqp_disp', "value" => 'false'}, 
                  {"id" => @ope.options[2].id, "name" => 'slsqp_maxiter', "value" => '10'}], resp['options']
  end
  
end
