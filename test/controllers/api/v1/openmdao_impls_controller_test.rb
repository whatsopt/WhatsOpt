# frozen_string_literal: true

require "test_helper"

class Api::V1::OpenmdaoImplsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mda = analyses(:cicav)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "should get openmdao impl" do
    get api_v1_mda_openmdao_impl_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should update openmdao impl parallel flag" do
    refute @mda.openmdao_impl.parallel_group
    put api_v1_mda_openmdao_impl_url(@mda), params: { openmdao_impl: { components: { parallel_group: true } }, requested_at: Time.now },
                                            as: :json, headers: @auth_headers
    assert_response :success
    @mda.reload
    assert @mda.openmdao_impl.parallel_group
  end

  test "should update openmdao impl use_units flag" do
    refute @mda.openmdao_impl.use_units
    put api_v1_mda_openmdao_impl_url(@mda), params: { openmdao_impl: { components: { use_units: true } }, requested_at: Time.now },
                                            as: :json, headers: @auth_headers
    assert_response :success
    @mda.reload
    assert @mda.openmdao_impl.use_units
  end

end
