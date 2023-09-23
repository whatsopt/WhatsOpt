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
    sa = JSON.parse(response.body)["sensitivity"]
    expected = { "saMethod" => "morris", "saResult" => {
                  "obj" => { "mu" => [0.65, 0.21000000000000005],
                  "mu_star" => [1.62, 0.3500000000000001],
                  "sigma" => [1.794107020219251, 0.41199514560246936],
                  "parameter_names" => ["x1", "z[0]"] } } }
    sa_obj = sa["saResult"]["obj"]
    expected_obj = expected["saResult"]["obj"]
    assert_not_nil sa_obj["mu_star_conf"]
    assert_equal(expected_obj["mu_star"], sa_obj["mu_star"])
    assert_equal(expected_obj["sigma"], sa_obj["sigma"])
    assert_equal(expected_obj["parameter_names"], sa_obj["parameter_names"])
  end

  test "should run salib sobol sensitivity analysis" do
    @ope = operations(:sobol_sensitivity)
    get api_v1_operation_sensitivity_analysis_url(@ope), as: :json, headers: @auth_headers
    assert_response :success
    sa = JSON.parse(response.body)["sensitivity"]
    expected = { "saMethod" => "sobol", "saResult" => { "obj" => {
      "S1" => [0.014617214325721908, 0.5749293377642799, -0.17990720667857346],
      "S1_conf" => [0.20703489110937862, 0.918324574201029, 0.19034180520043809],
      "ST" => [0.34703517959317715, 0.4068909153159429, 0.026851974301575657],
      "ST_conf" => [0.6297755534433752, 0.8538655815339021, 0.02195163588501736],
      "parameter_names" => ["x1", "z[0]", "z[1]"] } } }
    assert_equal expected["saMethod"], sa["saMethod"]
    sa_obj = sa["saResult"]["obj"]
    expected_obj = expected["saResult"]["obj"]
    assert_equal(expected_obj["S1"], sa_obj["S1"])
    assert_equal(expected_obj["ST"], sa_obj["ST"])
    assert_equal(expected_obj["parameter_names"], sa_obj["parameter_names"])
  end

  test "should return hsic sensitivity analysis" do
    @ope = operations(:doe_hsic)
    get api_v1_operation_sensitivity_analysis_url(@ope), as: :json, headers: @auth_headers
    assert_response :success
    hsic = JSON.parse(response.body)["sensitivity"]
    expected = {indices:[0.0014121409195806053, 0.001418468960398962, 0.0007061936384376915, 0.0002129569288513162, 8.460438189180596e-05], r2:[0.06803236078292796, 0.06834374947404051, 0.034028210220661076, 0.010262464507910463, 0.004078202941354846], pvperm:[0.0, 0.0, 0.009900990099009901, 0.3069306930693069, 0.900990099009901], pvas:[0.0003317619419649116, 0.0005081353448532153, 0.0016678701675430965, 0.39159553260140195, 0.8348439572390963]}
    assert_equal(hsic["indices"], expected[:indices]) 
    assert_equal(hsic["r2"], expected[:r2]) 
    hsic["pvas"].zip(expected[:pvas]).each do |act, exp|
      assert_in_delta(act, exp, delta=0.1) 
    end
    hsic["pvperm"].zip(expected[:pvperm]).each do |act, exp|
      assert_in_delta(act, exp, delta=0.1) 
    end
  end
end
