# frozen_string_literal: true

require "test_helper"

class CreateAndImportMetamodel < ActionDispatch::IntegrationTest
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
      { varname: varname, coord_index: coord_index, values: values }
    end

    post "/api/v1/operations", params: {
      operation: { 'name': "DOE LHS",
                  'driver': "smt_doe_lhs",
                  'host': "localhost",
                  'cases': cases,
                  'success': success },
      outvar_count_hint: 3
      },
      as: :json, headers: @auth_headers
    assert_response :success

    # doe_mda = Analysis.last
    ope = Operation.last

    assert_equal "DOE LHS", ope.name
    assert_equal Operation::CAT_DOE, ope.category

    # Create a SMT Kriging metamodel from previous DOE
    post "/api/v1/operations/#{ope.id}/meta_models", params: { meta_model: { kind: Surrogate::SMT_KRIGING } },
    as: :json, headers: @auth_headers
    assert_response :success

    mm_mda = Analysis.last
    assert_equal 3, mm_mda.response_variables.count
    assert_equal 2, mm_mda.design_variables.count

    mm_disc = mm_mda.disciplines.last

    # ope_doe = Operation.second_to_last
    # assert_equal Operation::CAT_DOE, ope_mm.category

    # ope_mm = Operation.last
    # assert_equal "Metamodel kriging", ope_mm.name
    # assert_equal Operation::CAT_METAMODEL, ope_mm.category

    # Create new analysis
    assert_difference("Analysis.count") do
      post mdas_url, params: {
        analysis: { name: "Test" } }
    end
    dest_mda = Analysis.last

    # Import metamodel
    put api_v1_mda_url(dest_mda), params: { analysis: { import: { analysis: mm_mda.id, disciplines: [mm_disc.id] } } },
        as: :json, headers: @auth_headers

    assert mm_mda.is_metamodel_prototype?
    assert_not dest_mda.is_metamodel_prototype?

    assert_difference("Analysis.count", 0) do
      assert_difference("Operation.count", 0) do
        delete "/analyses/#{mm_mda.id}"
      end
    end
    assert_redirected_to mdas_url
  end
end
