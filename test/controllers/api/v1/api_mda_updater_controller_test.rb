# frozen_string_literal: true

require "test_helper"

class Api::V1::ApiMdaUpdaterControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:user1)
    @user4 = users(:user4)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @auth_headers2 = { "Authorization" => "Token " + TEST_API_KEY + "User4" }
    @mda = analyses(:cicav)
    @past_reqtime = @mda.updated_at - 5.seconds
    @geometry = disciplines(:geometry)
    @aerodynamics = disciplines(:aerodynamics)
  end

  test "should raise an error on concurrent analysis update" do
    put api_v1_mda_url(@mda), params: { analysis: { name: "TestNewName" }, requested_at: @past_reqtime }, as: :json, headers: @auth_headers
    assert_response :conflict
  end

  test "should raise an error on concurrent discipline operation on an analysis" do
    post api_v1_mda_disciplines_url(@mda), params: {
        discipline: { name: "TestDiscipline", type: "analysis"
      }, requested_at: @past_reqtime }, as: :json, headers: @auth_headers
    assert_response :conflict
  end

  test "should raise an error on concurrent connection operation on an analysis" do
    post api_v1_mda_connections_url(mda_id: @mda.id, requested_at: @past_reqtime,
        connection: { from: @geometry.id, to: @aerodynamics.id, names: ["newvar"] }),
        as: :json, headers: @auth_headers
    assert_response :conflict
  end

  test "should raise an error on concurrent opendamo impl operation on an analysis" do
    put api_v1_mda_openmdao_impl_url(@mda), params: { openmdao_impl: { components: { use_units: true } }, requested_at: @past_reqtime },
    as: :json, headers: @auth_headers
    assert_response :conflict
  end

  test "should not raise conflict when previous update was an error" do
    time_ok = Time.now
    time_update = @mda.updated_at
    post api_v1_mda_connections_url(mda_id: @mda.id, requested_at: time_ok,
                                   connection: { from: @geometry.id, to: @aerodynamics.id, names: ["ya"] }),
                                   as: :json, headers: @auth_headers
    assert_response :unprocessable_content
    @mda.reload
    assert_equal time_update, @mda.updated_at
    post api_v1_mda_connections_url(mda_id: @mda.id, requested_at: time_ok,
                                   connection: { from: @geometry.id, to: @aerodynamics.id, names: ["toto"] }),
                                   as: :json, headers: @auth_headers
    assert_response :success
  end
end
