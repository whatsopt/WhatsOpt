require 'test_helper'

class OpenturnsSobolPceTest < ActionDispatch::IntegrationTest

  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "doe creation then metamodel creation and sobol analysis" do
    # sign_in(users("user1"))
    # post "/api/v1/operations", params: {
    #   operation: {'name': "doe test",
    #               'driver': "smt_doe_lhs",
    #               'host': "localhost",
    #               'cases': ,
    #               'success': },
    #   },
    #   as: :json, headers: @auth_headers

  end

end
