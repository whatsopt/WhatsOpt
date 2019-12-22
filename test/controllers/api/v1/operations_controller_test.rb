# frozen_string_literal: true

require "test_helper"
require "matrix"

class Api::V1::OperationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
    @ope = operations(:doe)
  end

  test "should create an operation with cases (upload)" do
    assert_difference("Operation.count", 1) do
      post api_v1_mda_operations_url(@mda),
        params: { operation: { name: "new_doe", cases: [{ varname: "x1", coord_index: 0, values: [10, 20, 30] },
                                                      { varname: "obj", coord_index: 0, values: [40, 50, 60] }
                                                      ],
                             success: [1, 0, 1]
                              }
                  },
          as: :json, headers: @auth_headers
    end
    assert_response :success
    @mda.reload
    get api_v1_operation_url(@mda.operations.last), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal "new_doe", resp["name"]
    assert_equal "runonce", resp["driver"]
    assert_equal 2, resp["cases"].length
    assert_equal ["obj", "x1"], resp["cases"].map { |c| c["varname"] }.sort
    assert_equal [0, 0], resp["cases"].map { |c| c["coord_index"] }.sort
    assert_equal [10, 20, 30, 40, 50, 60], resp["cases"].map { |c| c["values"] }.flatten.sort
    assert_equal({ "status" => "DONE_OFFLINE", "log" => "", "log_count" => 0, "start_in_ms" => 0.0, "end_in_ms" => 0.0 }, resp["job"])
  end

  test "should create an operation with LHS options" do
    assert_difference("Operation.count", 1) do
      post api_v1_mda_operations_url(@mda),
        params: { operation: { name: "new_doe", host: "localhost", driver: "lhs",
                             options_attributes: [{ name: "lhs_nbpts", value: "57" }] } },
        as: :json, headers: @auth_headers
    end
    assert_response :success
    opt = Operation.last.options.first
    assert_equal "lhs_nbpts", opt.name
    assert_equal "57", opt.value
  end

  test "should get an operation" do
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 3, resp["success"].size
  end

  test "should update an operation with cases" do
    patch api_v1_operation_url(@ope),
      params: { operation: { name: "update_doe", driver: "slsqp", cases: [{ varname: "x1", coord_index: 0, values: [4, 5] },
                                                                        { varname: "y2", coord_index: 0, values: [1, 2] }
                                                                       ], success: [1, 1] } },
      as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    resp = JSON.parse(response.body)
    assert_equal "update_doe", resp["name"]
    assert_equal "slsqp", resp["driver"]
    assert_equal ["x1", "y2"], resp["cases"].map { |c| c["varname"] }.sort
    assert_equal [0, 0], resp["cases"].map { |c| c["coord_index"] }.sort
    assert_equal [1, 2, 4, 5], resp["cases"].map { |c| c["values"] }.flatten.sort
    assert_equal "DONE_OFFLINE", resp["job"]["status"]
    assert_equal "this is a test job\nData uploaded\n", resp["job"]["log"]
  end

  test "should update an operation with LHS options" do
    patch api_v1_operation_url(@ope),
    params: { operation: { name: "update_doe", driver: "lhs",
                         cases: [],
                         success: [],
                         options_attributes: [{ id: @ope.options.first.id, name: "lhs_nbpts", value: 20 }] } },
      as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    resp = JSON.parse(response.body)
    assert_equal [{ "id" => @ope.options.first.id, "name" => "lhs_nbpts", "value" => "20" }], resp["options"]
  end

  test "should update an operation with SLSQP options" do
    prev_options_to_destroy = @ope.options.map { |opt| { id: opt.id, _destroy: 1 } }
    new_options = prev_options_to_destroy + [{ name: "slsqp_tol", value: 1e-6 },
                                             { name: "slsqp_disp", value: false },
                                             { name: "slsqp_maxiter", value: 10 }]
    patch api_v1_operation_url(@ope),
    params: { operation: { name: "update_optim", driver: "slsqp",
                         cases: [],
                         success: [],
                         options_attributes: new_options } },
      as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
    resp = JSON.parse(response.body)
    @ope.reload
    assert_equal 3, @ope.options.length
    assert_equal [{ "id" => @ope.options[0].id, "name" => "slsqp_tol", "value" => "1.0e-06" },
                  { "id" => @ope.options[1].id, "name" => "slsqp_disp", "value" => "false" },
                  { "id" => @ope.options[2].id, "name" => "slsqp_maxiter", "value" => "10" }], resp["options"]
  end

  test "should create an operation from data" do
    assert_difference("Analysis.count", 1) do
      assert_difference("Operation.count", 1) do
        assert_difference("Variable.count", 4) do
          post api_v1_operations_url(),
            params: {
              operation: { name: "MyData",
                driver: "user_defined_algo",
                host: "localhost",
                cases: [{ varname: "x1", coord_index: 0, values: [10, 20, 30] },
                        { varname: "x1", coord_index: 1, values: [40, 50, 60] },
                        { varname: "obj", coord_index: -1, values: [70, 80, 90] }
                ],
                success: [1, 0, 1]
              }
            },
            as: :json, headers: @auth_headers
        end
      end
    end
    assert_response :success
    mda = Analysis.last
    assert_equal 1, mda.design_variables.count
    assert_equal 1, mda.response_variables.count
  end

  test "should create an operation from data with several outputs" do
    # assert_difference("Analysis.count", 1) do
    #   assert_difference("Operation.count", 1) do
    #     assert_difference("Variable.count", 6) do
    post api_v1_operations_url(),
      params: {
        operation: { name: "MyData",
          driver: "user_defined_algo",
          host: "localhost",
          cases: [{ varname: "x1", coord_index: -1, values: [10, 20, 30] },
                  { varname: "y", coord_index: -1, values: [10, 20, 30] },
                  { varname: "obj", coord_index: 0, values: [40, 50, 60] },
                  { varname: "obj", coord_index: 1, values: [70, 80, 90] }
          ],
          success: [1, 0, 1]
        },
        outvar_count_hint: 2
      },
      as: :json, headers: @auth_headers
    #     end
    #   end
    # end
    assert_response :success
    mda = Analysis.last
    assert_equal 1, mda.design_variables.count
    assert_equal 2, mda.response_variables.count
  end

  test "should create a DOE morris with sensitivity analysis operation" do
    inputs = Matrix[[0, 1.0 / 3], [0, 1], [2.0 / 3, 1],
      [0, 1.0 / 3], [2.0 / 3, 1.0 / 3], [2.0 / 3, 1],
      [2.0 / 3, 0], [2.0 / 3, 2.0 / 3], [0, 2.0 / 3],
      [1.0 / 3, 1], [1, 1], [1, 1.0 / 3],
      [1.0 / 3, 1], [1.0 / 3, 1.0 / 3], [1, 1.0 / 3],
      [1.0 / 3, 2.0 / 3], [1.0 / 3, 0], [1, 0]]
    output = [0.97, 0.71, 2.39, 0.97, 2.30, 2.39,
      1.87, 2.40, 0.87, 2.15, 1.71, 1.54,
      2.15, 2.17, 1.54, 2.20, 1.87, 1.0]
    assert_difference('Operation.count', 2) do
      post api_v1_operations_url(),
        params: {
          operation: { name: "DOE morris",
            driver: "salib_doe_morris",
            host: "localhost",
            cases: [{ varname: "x1", coord_index: -1, values: inputs.column(0).to_a },
                    { varname: "x2", coord_index: -1, values: inputs.column(0).to_a },
                    { varname: "y", coord_index: -1, values: output }],
            success: [1]*output.size
          },
          outvar_count_hint: 1
        },
        as: :json, headers: @auth_headers
      assert_response :success  
      derived = Operation.last
      base = Operation.second_to_last
      assert_equal "salib_doe_morris", base.driver 
      assert_equal "salib_sensitivity_morris", derived.driver
      assert_equal derived, base.derived_operations.first
      assert derived.success? 

      get api_v1_operation_openmdao_screening_url(derived), as: :json, headers: @auth_headers
      assert_response :success
    end
  end
end
