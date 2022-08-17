# frozen_string_literal: true

require "test_helper"

class OptimizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @ack = optimizations(:optim_ackley2d)
    @unstat = optimizations(:optim_unkown_status)
  end

  test "should get index" do
    get optimizations_url
    assert_response :success
    assert_select "tbody>tr", count: Optimization.owned_by(users(:user1)).size
  end

  test "admin should destroy optimization" do
    sign_out users(:user1)
    sign_in users(:admin)
    assert_difference("Optimization.count", -1) do
      post select_optimizations_path, params: { delete: "-", optimization_request_ids: [@ack.id] }
      assert_redirected_to optimizations_url
    end
  end

  test "non-owner cannot destroy optimization" do
    assert_difference("Optimization.count", 0) do
      post select_optimizations_path, params: { delete: "-", optimization_request_ids: [@unstat.id] }
    end
  end

  test "should get log file" do
    skip_if_segomoe_not_installed
    @ack.create_optimizer
    get optimization_download_path(@ack.id)
    assert_response :success
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

  test "should authorized access by default" do
    post optimizations_url, params: { optimization: { kind: "SEGOMOE", xlimits: ["1, 2", "3, 4"], options: ["", ""] } }
    sign_out users(:user1)
    sign_in users(:user2)
    get optimization_url(Optimization.last)
    assert_response :found
  end

  test "should not delete by default" do
    assert_difference("Optimization.count", 0) do
      post select_optimizations_path, params: {optimization_request_ids: [@ack.id, @unstat.id] }
    end
  end

  test "should compare the optimizations" do 
    sign_out users(:user1)
    sign_in users(:admin)
    post select_optimizations_path, params: {optimization_request_ids: [@ack.id, @unstat.id] }
    assert_redirected_to controller: 'optimizations', action: 'compare', optim_list: [@ack.id, @unstat.id]
  end
end
