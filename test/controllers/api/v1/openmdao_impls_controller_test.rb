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
    assert_not @mda.openmdao_impl.parallel_group
    put api_v1_mda_openmdao_impl_url(@mda), params: { openmdao_impl: { parallel_group: true }, requested_at: Time.now },
                                            as: :json, headers: @auth_headers
    assert_response :success
    @mda.reload
    assert @mda.openmdao_impl.parallel_group
  end

  test "should update openmdao impl use_units flag to true" do
    assert_not @mda.openmdao_impl.use_units
    put api_v1_mda_openmdao_impl_url(@mda), params: { openmdao_impl: { use_units: true }, requested_at: Time.now },
                                            as: :json, headers: @auth_headers
    assert_response :success
    @mda.reload
    assert @mda.openmdao_impl.use_units
  end

  test "should update openmdao impl use_units flag to false" do
    @mda.openmdao_impl.update(use_units: true)
    put api_v1_mda_openmdao_impl_url(@mda), params: { openmdao_impl: { use_units: false }, requested_at: Time.now },
                                            as: :json, headers: @auth_headers
    assert_response :success
    @mda.reload
    assert_not @mda.openmdao_impl.use_units
  end

  test "should update openmdao impl optim driver" do
    assert_not @mda.openmdao_impl.use_units
    put api_v1_mda_openmdao_impl_url(@mda), params: { openmdao_impl: { optimization_driver: :onerasego_optimizer_segomoe }, requested_at: Time.now },
                                            as: :json, headers: @auth_headers
    assert_response :success
    @mda.reload
    assert_equal "onerasego_optimizer_segomoe", @mda.openmdao_impl.optimization_driver
  end

  test "should propagate use_units change" do
    outermda = analyses(:outermda)
    outermda.openmdao_impl
    innermda = analyses(:innermda)
    inner_oimpl = innermda.openmdao_impl
    assert_not inner_oimpl.use_units
    put api_v1_mda_openmdao_impl_url(outermda), params: { openmdao_impl: { use_units: true }, requested_at: Time.now },
    as: :json, headers: @auth_headers
    assert_response :success
    inner_oimpl.reload
    assert inner_oimpl.use_units
  end
end
