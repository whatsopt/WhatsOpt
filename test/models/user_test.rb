# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "could own an MDA" do
    user = users(:user1)
    mda = analyses(:cicav)
    assert user.has_role?(:owner, mda)
  end
end
