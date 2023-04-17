# frozen_string_literal: true

require "test_helper"

class PackagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @cicav = analyses(:cicav)
    @singl = analyses(:singleton)
  end

  test "should get index" do
    get packages_url
    assert_response :success
    assert_select "tbody>tr", count: Package.count
  end

  test "owner should destroy package" do
    @pkg = packages(:cicav_pkg)
    assert_difference("Package.count", -1) do
      delete package_url(@pkg)
      assert_redirected_to packages_url
    end
  end

  test "co-owner should not destroy package" do
    sign_in users(:user4)
    @pkg = packages(:cicav_pkg)
    assert_difference("Package.count", 0) do
      delete package_url(@pkg)
      assert_redirected_to root_url
    end
  end

  test "non-owner cannot destroy package" do
    @pkg = packages(:cicav_pkg)
    sign_out users(:user1)
    user2 = users(:user2)
    sign_in user2
    assert_difference("Package.count", 0) do
      delete package_url(@pkg)
    end
  end
end
