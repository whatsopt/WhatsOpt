require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should have a user default role" do
    user = users(:user1)
    assert user.has_role?(:user)
  end
  
  test "could own an MDA" do
    user = users(:user1)
    mda = multi_disciplinary_analyses(:cicav)
    assert user.has_role?(:owner, mda)
  end

end
