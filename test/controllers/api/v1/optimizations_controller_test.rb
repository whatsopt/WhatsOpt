# frozen_string_literal: true

require "test_helper"
require "matrix"

class Api::V1::OptimizationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "should create an optimization" do
    assert_difference("Optimization.count", 1) do
      post api_v1_optimizations_url,
        params: { optimization: { kind: "SEGOMOE",
                                  xlimits: [[-32.768, 32.768], [-32.768, 32.768]],
                              }
                  },
          as: :json, headers: @auth_headers
    end
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal "SEGOMOE", resp['kind']
  end

  # test "should get an operation" do
  #   get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
  #   assert_response :success
  #   resp = JSON.parse(response.body)
  #   assert_equal 5, resp["success"].size
  # end

  # test "should update an operation with cases" do
  #   patch api_v1_operation_url(@ope),
  #     params: { operation: { name: "update_doe", driver: "slsqp", cases: [{ varname: "x1", coord_index: 0, values: [4, 5] },
  #                                                                       { varname: "y2", coord_index: 0, values: [1, 2] }
  #                                                                      ], success: [1, 1] } },
  #     as: :json, headers: @auth_headers
  #   assert_response :success
  #   get api_v1_operation_url(@ope), as: :json, headers: @auth_headers
  #   resp = JSON.parse(response.body)
  #   assert_equal "update_doe", resp["name"]
  #   assert_equal "slsqp", resp["driver"]
  #   assert_equal ["x1", "y2"], resp["cases"].map { |c| c["varname"] }.sort
  #   assert_equal [0, 0], resp["cases"].map { |c| c["coord_index"] }.sort
  #   assert_equal [1, 2, 4, 5], resp["cases"].map { |c| c["values"] }.flatten.sort
  #   assert_equal "DONE_OFFLINE", resp["job"]["status"]
  #   assert_equal "this is a test job\nData uploaded\n", resp["job"]["log"]
  # end

end
