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

  test "should update and get an optimization" do
    @optim = optimizations(:optim_ackley2d)
    @optim.create_optimizer

    patch api_v1_optimization_url(@optim),
      params: { optimization: { x: [[0.1005624023, 0.1763338461],
                                [0.843746558, 0.6787895599],
                                [0.3861691997, 0.106018846]], 
                             y: [[9.09955542], [6.38231049], [12.4677347]]}},
      as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    status = resp['status']
    assert_equal 0, status
    x = resp['x_suggested']
    assert_in_delta(0.85, x[0], 0.5)
    assert_in_delta(0.66, x[1], 0.5)

    get api_v1_optimization_url(@optim), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_in_delta(0.85, resp['outputs']['x_suggested'][0], 0.5)
    assert_in_delta(0.66, resp['outputs']['x_suggested'][1], 0.5)
  end
end
