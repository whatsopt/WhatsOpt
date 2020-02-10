require 'test_helper'

class CreatePCESensitivityAnalysis < ActionDispatch::IntegrationTest

  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "doe creation then metamodel creation and sobol analysis" do
    sign_in(users("user1"))

    # DOE creation by uploading data
    data = csv2hash("lhs100.csv")
    success = data["success"]
    varcases = data.except("success")
    cases = varcases.map do |var, values|
      varname, coord_index = var, -1
      if var =~ /(\w+)\[(\d+)\]/
        varname = $1
        coord_index = $2
      end
      {varname: varname, coord_index: coord_index, values: values}
    end

    post "/api/v1/operations", params: {
      operation: {'name': "DOE LHS",
                  'driver': "smt_doe_lhs",
                  'host': "localhost",
                  'cases': cases,
                  'success': success},
      outvar_count_hint: 3
      },
      as: :json, headers: @auth_headers
    assert_response :success
    
    doe_mda = Analysis.last

    ope = Operation.last

    assert_equal "DOE LHS", ope.name
    assert_equal Operation::CAT_DOE, ope.category

    # Create an OpenTURNS PCE metamodel from previous DOE
    post "/api/v1/operations/#{ope.id}/meta_models", params: { meta_model: {kind: Surrogate::OPENTURNS_PCE }},
    as: :json, headers: @auth_headers
    assert_response :success

    mm_mda = Analysis.last

    ope_doe = Operation.third_to_last
    assert_equal Operation::CAT_DOE, ope_doe.category

    ope_mm = Operation.second_to_last
    assert_equal "Metamodel pce", ope_mm.name
    assert_equal Operation::CAT_METAMODEL, ope_mm.category

    ope_sa = Operation.last
    assert_equal "Sensitivity pce", ope_sa.name
    assert_equal Operation::CAT_SENSITIVITY, ope_sa.category

    get "/api/v1/operations/#{ope_sa.id}/sensitivity_analysis", as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)

    # Metamodel operation removal is forbidden due to Sensitivity operaition dependency
    delete "/api/v1/operations/#{ope_mm.id}", as: :json, headers: @auth_headers
    assert_response :forbidden
    delete "/operations/#{ope_mm.id}"
    assert_redirected_to mdas_url

    assert_difference('Analysis.count', -1) do
      assert_difference('Operation.count', -3) do
        delete "/analyses/#{ope_mm.analysis.id}"
      end
    end
    assert_redirected_to mdas_url
  end

end
