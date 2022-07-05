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
      delete destroy_selected_optimizations_path, params: { optimization_request_ids: [@ack.id] }
      assert_redirected_to optimizations_url
    end
  end

  test "non-owner cannot destroy optimization" do
    assert_difference("Optimization.count", 0) do
      delete destroy_selected_optimizations_path, params: { optimization_request_ids: [@unstat.id] }
    end
  end

  test "should not show non-owned optimizations" do
    sign_out users(:user1)
    sign_in users(:user2)
    get optimizations_url
    assert_response :success
    assert_select "tbody>tr", count: 0
  end
end
