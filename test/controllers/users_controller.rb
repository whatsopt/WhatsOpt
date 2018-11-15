require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user1 = users(:user1)
    sign_in @user1
  end
  
  test "should get user profile" do
    get user_url(@user1)
    assert_response :success
  end
  
end