# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "could own an MDA" do
    user = users(:user1)
    mda = analyses(:cicav)
    assert user.has_role?(:owner, mda)
  end

  test "should not validate complexity on creation" do
    user = User.create!(login: "Test", email: "fdsfd@onera.fr", password: "too_simple", password_confirmation: "too_simple")
    user.update(password: "too_simple", password_confirmation: "too_simple")
    assert user.password
  end

  test "should deactivate when destroying" do
    user1 = users(:user1)
    assert_equal false, !!user1.deactivated
    user1.destroy
    assert_equal 1, User.where(id: user1.id).count
    user1.reload
    assert_equal true, user1.deactivated
  end

  test "should deactivate when destroying!" do
    user1 = users(:user1)
    assert_equal false, !!user1.deactivated
    user1.destroy!
    assert_equal 1, User.where(id: user1.id).count
    user1.reload
    assert_equal true, user1.deactivated
  end
end
