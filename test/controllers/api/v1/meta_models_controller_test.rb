# frozen_string_literal: true

require "test_helper"

class Api::V1::MetaModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
    @ope = operations(:doe)
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
    assert_equal 1, mda.response_variables.count
  end
end
