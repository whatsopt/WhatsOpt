require 'test_helper'

class Api::V1::OpenmdaoImplsControllerTest < ActionDispatch::IntegrationTest

  test "should update openmdao impl" do
    put api_v1_mda_openmdao_impl_url(@mda), {openmdao_impl: {parallel_group: true}}, as: :json, headers: @auth_headers
    assert_response :success
  end

end
