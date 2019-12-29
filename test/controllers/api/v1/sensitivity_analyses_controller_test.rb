# frozen_string_literal: true

require "test_helper"
require "json"

class Api::V1::SensitivityAnalysisControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "should run morris sensitivity analysis" do
    @ope = operations(:morris_sensitivity)
    get api_v1_operation_sensitivity_analysis_url(@ope), as: :json, headers: @auth_headers
    assert_response :success
    sa = JSON.parse(response.body)
    expected = {"saMethod"=>"morris", "saResult"=>{
                  "obj"=>{"mu"=>[0.65, 0.21000000000000005], 
                  "mu_star"=>[1.62, 0.3500000000000001], 
                  "sigma"=>[1.794107020219251, 0.41199514560246936], 
                  "parameter_names"=>["x1", "z[0]"]}}}
    assert_equal expected, sa["sensitivity"]
  end

  test "should run sobol sensitivity analysis" do
    @ope = operations(:sobol_sensitivity)
    get api_v1_operation_sensitivity_analysis_url(@ope), as: :json, headers: @auth_headers
    assert_response :success
    sa = JSON.parse(response.body)['sensitivity']
    expected = {"saMethod"=>"sobol", "saResult"=>{"obj"=>{
      "S1"=>[0.014617214325721908, 0.5749293377642799, -0.17990720667857346], 
      "S1_conf"=>[0.20703489110937862, 0.918324574201029, 0.19034180520043809], 
      "ST"=>[0.34703517959317715, 0.4068909153159429, 0.026851974301575657], 
      "ST_conf"=>[0.6297755534433752, 0.8538655815339021, 0.02195163588501736], 
      "parameter_names"=>["x1", "z[0]", "z[1]"  ]}}}
    assert_equal expected["saMethod"], sa["saMethod"]
    sa_obj = sa["saResult"]["obj"]
    expected_obj = expected["saResult"]["obj"]
    assert_equal expected_obj["S1"], sa_obj["S1"]
    assert_equal expected_obj["ST"], sa_obj["ST"]
    assert_equal expected_obj["parameter_names"], sa_obj["parameter_names"]
  end

end
