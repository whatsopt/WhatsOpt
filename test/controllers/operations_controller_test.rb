# frozen_string_literal: true

require "test_helper"

class OperationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @mda = analyses(:cicav)
    @ope = operations(:doe)
  end

  test "should get an operation" do
    get operation_url(@ope)
    assert_response :success
  end
end
