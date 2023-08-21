# frozen_string_literal: true

require "test_helper"

class OptimizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @optim_ack = optimizations(:optim_ackley2d)
    @optim_unknown_status = optimizations(:optim_unknown_status)
  end

  test "should get index of is owned optimizations" do
    get optimizations_url
    assert_response :success
    assert_select "tbody>tr", count: Optimization.owned_by(users(:user1)).size
  end

  test "SEGO experts should get read access to all optimizations" do
    sign_out users(:user1)
    sign_in users(:user2)
    get optimizations_url
    assert_response :success
    assert_select "tbody>tr", count: Optimization.count
  end

  test "admin can destroy optimization" do
    sign_out users(:user1)
    sign_in users(:admin)
    assert_difference("Optimization.count", -1) do
      post select_optimizations_path, params: { delete: "-", optimization_request_ids: [@optim_ack.id] }
      assert_redirected_to optimizations_url
    end
  end

  test "SEGO expert cannot destroy optimization" do
    sign_out users(:user1)
    sign_in users(:user2)
    assert_difference("Optimization.count", 0) do
      post select_optimizations_path, params: { delete: "-", optimization_request_ids: [@optim_ack.id] }
      assert_redirected_to root_url
    end
  end

  test "non-owner cannot destroy optimization" do
    sign_out users(:user1)
    sign_in users(:user3)
    assert_difference("Optimization.count", 0) do
      post select_optimizations_path, params: { delete: "-", optimization_request_ids: [@optim_ack.id] }
      assert_response :redirect
    end
  end

  test "non-owner cannot update optimization" do
    sign_out users(:user1)
    sign_in users(:user3)
    assert_difference("Optimization.count", 0) do
      patch optimization_path(@optim_ack), params: { inputs: { x: [1.0], y: [2.0] } }
      assert_response :redirect
    end
  end

  test "should get new" do
    get new_optimization_url
    assert_response :success
  end

  test "should create pending optimization" do
    assert_difference("Optimization.count") do
      post optimizations_url, params: { optimization: { kind: "SEGOMOE", xlimits: ["1, 2", "3, 4"], options: ["", ""] } }
    end
    assert_equal Optimization.last.outputs["status"], -1
    assert_redirected_to optimizations_url
  end

  test "should assign owner on creation" do
    post optimizations_url, params: { optimization: { kind: "SEGOMOE", xlimits: ["1, 2", "3, 4"], options: ["", ""] } }
    assert Optimization.last.owner, users(:user1)
  end

  test "should authorized read access by default to any single optimization" do
    sign_out users(:user1)
    sign_in users(:user2)
    get optimization_url(@optim_ack)
    assert_response :success
  end

  test "should not delete by default" do
    assert_difference("Optimization.count", 0) do
      post select_optimizations_path, params: { optimization_request_ids: [@optim_ack.id, @optim_unknown_status.id] }
    end
  end

  test "should compare the optimizations" do
    sign_out users(:user1)
    sign_in users(:admin)
    post select_optimizations_path, params: { optimization_request_ids: [@optim_ack.id, @optim_unknown_status.id] }
    assert_redirected_to controller: "optimizations", action: "compare", optim_list: [@optim_ack.id, @optim_unknown_status.id]
  end

  test "should add an input to the optimization" do
    put optimization_path(@optim_ack), params: { optimization: { inputs: { x: ["0, 0"], y: ["0"] } } }
    assert_redirected_to optimization_path(@optim_ack)
  end

  test "should not add invalid input" do
    put optimization_path(@optim_ack), params: { optimization: { inputs: { x: ["0"], y: ["0"] } } }
    assert_redirected_to edit_optimization_path(@optim_ack)
  end

  test "should not be able to create too many optimizations" do
    Optimization::MAX_OPTIM_NUMBER.times { |i| post optimizations_url, params: { optimization: { kind: "SEGOMOE", xlimits: ["1, 2", "3, 4"], options: ["", ""] } } }
    post optimizations_url, params: { optimization: { kind: "SEGOMOE", xlimits: ["1, 2", "3, 4"], options: ["", ""] } }
    assert_response :redirect
    assert_equal Optimization::MAX_OPTIM_NUMBER, Optimization.owned_by(users(:user1)).size
  end
end
