# frozen_string_literal: true

require "test_helper"

class Api::V1::MetaModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mda = analyses(:cicav)
    @ope = operations(:doe)
    @user = users(:user1)
    @auth_headers = { "Authorization" => "Token " + @user.api_key }
    @user2 = users(:user2)
    @auth_headers2 = { "Authorization" => "Token " + @user2.api_key }
    @user3 = users(:user3)
    @auth_headers3 = { "Authorization" => "Token " + @user3.api_key }
  end

  teardown do
    WhatsOpt::SurrogateProxy.shutdown_server
  end

  test "should get list of metamodels for user1" do
    get api_v1_meta_models_url, as: :json, headers: @auth_headers
    assert_response :success
    mms = JSON.parse(response.body)
    assert_equal 2, mms.count  # out of 2 primary mm, one is private for user3 and user1 member
    assert_equal ["created_at", "id", "name", "owner_email"], mms.first.keys.sort 
  end

  test "should get list of metamodels for user2" do
    get api_v1_meta_models_url, as: :json, headers: @auth_headers2
    assert_response :success
    mms = JSON.parse(response.body)
    assert_equal 1, mms.count   # out of 2 primary mm, one is private for user3 and user1 member  
  end

  test "should get list of metamodels for user3" do
    get api_v1_meta_models_url, as: :json, headers: @auth_headers3
    assert_response :success
    mms = JSON.parse(response.body)
    assert_equal 2, mms.count   # out of 2 primary mm, one is private for user3 and user1 member
  end

  test "should show a metamodel" do
    mm = meta_models(:cicav_metamodel)
    get api_v1_meta_model_url(mm), as: :json, headers: @auth_headers
    assert_response :success
    mminfos = JSON.parse(response.body)
    assert_equal ["created_at", "id", "name", "notes", "owner_email", "xlabels", "ylabels"], mminfos.keys.sort 
    assert_equal ["x1", "z[0]", "z[1]"], mminfos["xlabels"] 
    assert_equal ["obj"], mminfos["ylabels"] 
    assert_equal "", mminfos["notes"]
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
    mda = Analysis.second_to_last
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
        x: [[3, 5, 7], [6, 10, 1]]
      } }, as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    y = resp["y"]
    assert_in_delta(2.444, y[0][0])
    assert_in_delta(7.816, y[1][0])
  end

  test "anybody can make prediction" do
    mm = meta_models(:cicav_metamodel)
    @auth_headers = { "Authorization" => "Token " + @user2.api_key }
    put api_v1_meta_model_url(mm), params: { meta_model: {
        x: [[3, 5, 7], [6, 10, 1]]
      } }, as: :json, headers: @auth_headers
    assert_response :success
  end
end
