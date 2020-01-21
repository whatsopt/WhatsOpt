# frozen_string_literal: true

require "test_helper"

class Api::V1::MetaModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mda = analyses(:cicav)
    @ope = operations(:doe)
    @user = users(:user1)
    @auth_headers = { "Authorization" => "Token " + @user.api_key }
    @user2 = users(:user2)
  end

  teardown do
    WhatsOpt::SurrogateProxy.shutdown_server
  end

  test "should create a metamodel" do
    assert_difference("Analysis.count", 1) do
      assert_difference("Operation.count", 2) do # doe copy + metamodel
        assert_difference("MetaModel.count", 1) do
          assert_difference("Surrogate.count", 1) do
            post api_v1_operation_meta_models_url(@ope), 
              params: { meta_model: { kind: Surrogate::SMT_KPLS } }, 
              as: :json, headers: @auth_headers
          end
        end
      end
    end
    ope = Operation.last
    assert_response :success
    mda = Analysis.last
    assert_equal 2, mda.design_variables.count
    assert_equal 1, mda.response_variables.count
    x1 = mda.design_variables.first
    assert_equal "1", x1.parameter.lower
    assert_equal "10", x1.parameter.upper
    z = mda.design_variables.second
    assert_equal "1", z.parameter.lower
    assert_equal "10", z.parameter.upper
    assert_equal 1, mda.response_variables.count
    mm = MetaModel.last
    assert_equal @ope.attributes.except("id", "analysis_id"), 
                 mm.operation.base_operation.attributes.except("id", "analysis_id")
    assert_equal mda.disciplines.last, mm.discipline
    assert_equal Surrogate::SMT_KPLS, mm.default_surrogate_kind
    assert_equal 1, mm.surrogates.count
    surr = Surrogate.last
    assert_equal surr, mm.surrogates.first
    assert_equal mm.default_surrogate_kind, surr.kind
    assert_equal(-1, surr.coord_index)  # obj is a scalar
    assert_equal @user, mm.discipline.analysis.owner
  end

  test "should take into account variables selection" do
    post api_v1_operation_meta_models_url(@ope), params: {
      meta_model: { kind: Surrogate::SMT_KRIGING, variables: { inputs: ["x1"], outputs: ["obj"] } }
    }, as: :json, headers: @auth_headers
    ope = Operation.last
    assert_response :success
    mda = Analysis.last
    assert_equal 1, mda.design_variables.count
    assert_equal 1, mda.response_variables.count
  end

  test "should create a sensitivity operation with openturns pce metamodel" do
    post api_v1_operation_meta_models_url(@ope), params: {
      meta_model: { kind: Surrogate::OPENTURNS_PCE, variables: { inputs: ["x1"], outputs: ["obj"] } }
    }, as: :json, headers: @auth_headers
    ope_mm = Operation.second_to_last
    assert_equal Operation::CAT_METAMODEL, ope_mm.category
    assert_response :success
    ope_sa = Operation.last
    assert_equal Operation::CAT_SENSITIVITY, ope_sa.category
  end

  test "should show error if bad metamodel kind" do
    post api_v1_operation_meta_models_url(@ope), params: {
      meta_model: { kind: "BAD KIND" }
    }, as: :json, headers: @auth_headers
    assert_response :bad_request
    assert_match /Unknown metamodel/, response.body
  end

  test "should use a metamodel" do
    mm = meta_models(:cicav_metamodel)
    put api_v1_meta_model_url(mm), params: { meta_model: {
        format: "matrix", values: [[3, 5, 7], [6, 10, 1]]
      } }, as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    responses = resp["responses"]
    assert_in_delta(2.444, responses[0][0])
    assert_in_delta(7.816, responses[1][0])
  end

  test "anybody can make prediction" do
    mm = meta_models(:cicav_metamodel)
    @auth_headers = { "Authorization" => "Token " + @user2.api_key }
    put api_v1_meta_model_url(mm), params: { meta_model: {
        format: "matrix", values: [[3, 5, 7], [6, 10, 1]]
      } }, as: :json, headers: @auth_headers
    assert_response :success
  end
end
