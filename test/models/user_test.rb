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
  end
end
