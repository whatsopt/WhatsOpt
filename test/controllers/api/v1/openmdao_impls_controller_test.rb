require 'test_helper'

class Api::V1::OpenmdaoImplsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @mda = analyses(:cicav)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
  end

  test "should update openmdao impl" do
    put api_v1_mda_openmdao_impl_url(@mda), params: {openmdao_impl: {components: {parallel_execution: true}}}, as: :json, headers: @auth_headers
    assert_response :success
  end

end
