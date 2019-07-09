# frozen_string_literal: true

require "test_helper"

class Api::V1::MetaModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
    @ope = operations(:doe)
    @user = users(:user1)
  end

  test "should create a metamodel" do
    assert_difference("Analysis.count", 1) do
      assert_difference("MetaModel.count", 1) do
        assert_difference("Surrogate.count", 1) do
          post api_v1_operation_meta_models_url(@ope),
            as: :json, headers: @auth_headers
        end
      end
    end
    assert_response :success
    mda = Analysis.last
    assert_equal 2, mda.design_variables.count
    x1 = mda.design_variables.first
    assert_equal "1", x1.parameter.lower
    assert_equal "10", x1.parameter.upper
    z = mda.design_variables.second
    assert_equal "1", z.parameter.lower
    assert_equal "10", z.parameter.upper
    assert_equal 1, mda.response_variables.count
    mm = MetaModel.last
    assert_equal @ope, mm.operation
    assert_equal mda, mm.analysis
    assert_equal Surrogate::SURROGATES[0], mm.default_surrogate_kind
    assert_equal 1, mm.surrogates.count
    surr = Surrogate.last
    assert_equal surr, mm.surrogates.first
    assert_equal mm.default_surrogate_kind, surr.kind
    assert_equal -1, surr.coord_index  # obj is a scalar
    assert_equal @user, mm.analysis.owner
  end

  test "should use a metamodel" do
    mm = meta_models(:cicav_metamodel)
    put api_v1_meta_model_url(mm), params: {meta_model: {
        format: 'matrix',
        values: [[3, 5, 7], [6, 10, 1]]
      }}, as: :json, headers: @auth_headers
    assert_response :success
  end

end
