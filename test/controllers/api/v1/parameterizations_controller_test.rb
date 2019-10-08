# frozen_string_literal: true

require "test_helper"

class Api::V1::ParametrizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
  end

  test "should update analysis parameterization" do
    parameterization = [{ varname: "x1", value: "3" }, { varname: "z", value: "[4, 5]" }]
    patch api_v1_mda_parameterization_url(@mda),
          params: { parameterization: { parameters: parameterization } },
          as: :json, headers: @auth_headers
    assert_equal parameterization, @mda.driver.output_variables.map { |v| { varname: v.name, value: v.parameter.init } }
  end
end
