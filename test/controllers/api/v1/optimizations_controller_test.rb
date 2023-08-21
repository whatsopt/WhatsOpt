# frozen_string_literal: true

require "test_helper"
require "matrix"

class Api::V1::OptimizationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    # Bug: https://github.com/rails/rails/issues/37270 : test_adapter overrides backgroundjob runner
    (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
  end

  test "should create an optimization" do
    skip_if_parallel
    skip_if_segomoe_not_installed
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
    assert_equal "SEGOMOE", resp["kind"]
    assert_equal(resp["config"], { "xlimits" => [[-32.768, 32.768], [-32.768, 32.768]], "options" => {}, "n_obj" => 1, "cstr_specs" => [], "xtypes" => [] })
  end

  test "should raise error on xlimits absence" do
    skip_if_parallel
    assert_difference("Optimization.count", 0) do
      post api_v1_optimizations_url,
        params: { optimization: { kind: "SEGOMOE" } }, as: :json, headers: @auth_headers
    end
    assert_response :bad_request
  end

  test "should raise error on ill formed xlimits" do
    skip_if_parallel
    assert_difference("Optimization.count", 0) do
      post api_v1_optimizations_url,
        params: { optimization: { kind: "SEGOMOE", xlimits: [1, 2, 3] } }, as: :json, headers: @auth_headers
    end
    assert_response :bad_request
  end

  test "should update and get an optimization" do
    skip_if_parallel
    skip_if_segomoe_not_installed
    @optim = optimizations(:optim_ackley2d)
    @optim.create_optimizer

    patch api_v1_optimization_url(@optim),
      params: { optimization: { x: [[0.1005624023, 0.1763338461],
                                [0.843746558, 0.6787895599],
                                [0.3861691997, 0.106018846]],
                             y: [[9.09955542], [6.38231049], [12.4677347]] } },
      as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_optimization_url(@optim), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    status = resp["outputs"]["status"]
    assert_equal 0, status
    x = resp["outputs"]["x_suggested"]
    # value not checked as optim is stochastic
    # assert_in_delta(0.85, x[0], 0.5)
    # assert_in_delta(0.66, x[1], 0.5)

    get api_v1_optimization_url(@optim), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    # assert_in_delta(0.85, resp["outputs"]["x_suggested"][0], 0.5)
    # assert_in_delta(0.66, resp["outputs"]["x_suggested"][1], 0.5)

    optimizer_pkl = File.join(Rails.root, "upload", "store", "optimizer_#{@optim.id}.pkl")
    logfile = File.join(Rails.root, "log", "optimizations", "optim_#{@optim.id}.log")
    assert File.exist?(optimizer_pkl)
    assert File.exist?(logfile)
    assert_difference('Optimization. count', -1) do
      delete api_v1_optimization_url(@optim), as: :json, headers: @auth_headers
    end
    refute File.exist?(optimizer_pkl)
    refute File.exist?(logfile)
    WhatsOpt::OptimizerProxy.shutdown_server
  end

  test "should not be able to create too many optimizations" do
    skip_if_parallel
    skip_if_segomoe_not_installed
    Optimization::MAX_OPTIM_NUMBER.times do |_|
      post api_v1_optimizations_url,
        params: { optimization: { kind: "SEGOMOE",
                                  xlimits: [[-32.768, 32.768], [-32.768, 32.768]],
                              }
                  },
        as: :json, headers: @auth_headers
    end
    post api_v1_optimizations_url, params: { optimization: { kind: "SEGOMOE", xlimits: ["1, 2", "3, 4"] } },
        as: :json, headers: @auth_headers
    assert_response :bad_request
    assert_equal Optimization::MAX_OPTIM_NUMBER, Optimization.owned_by(users(:user1)).size
  end
end
