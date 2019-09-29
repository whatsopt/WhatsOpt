# frozen_string_literal: true

require "test_helper"

class Api::V1::DisciplineControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
    @disc = disciplines(:geometry)
    @disc2 = disciplines(:aerodynamics)
  end

  test "should get given discipline" do
    get api_v1_discipline_url(@disc), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal "Geometry", resp["name"]
    assert_equal "analysis", resp["type"]
  end

  test "should create discipline in given mda" do
    assert_difference("Discipline.count") do
      post api_v1_mda_disciplines_url(@mda), params: { discipline: { name: "TestDiscipline", type: "analysis" } }, as: :json, headers: @auth_headers
    end
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal "TestDiscipline", resp["name"]
    assert_equal @mda.id, resp["analysis_id"]
    assert_equal @mda.disciplines.count - 1, resp["position"]
  end

  test "should update discipline" do
    assert_equal "Geometry", @disc.name
    assert_equal "analysis", @disc.type
    assert_equal 1, @disc.position
    assert_equal 2, @disc2.position
    patch api_v1_discipline_url(@disc), params: { discipline: {  name: "NewName", type: "function", position: 2 } }, as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_discipline_url(@disc), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal "NewName", resp["name"]
    assert_equal "function", resp["type"]
    assert_equal 2, resp["position"].to_i
    @disc2.reload
    assert_equal 1, @disc2.position
  end

  test "should delete discipline and related variables" do
    initial_drivervar_count = @disc.analysis.driver.variables.count
    assert_difference("Discipline.count", -1) do
      delete api_v1_discipline_url(@disc), as: :json, headers: @auth_headers
      assert_response :success
      drivervar_count = @disc.analysis.driver.variables.reload.count
      assert_equal initial_drivervar_count - 2, drivervar_count
    end
  end

  test "should update discipline with an endpoint" do
    patch api_v1_discipline_url(@disc), params: { discipline: { endpoint_attributes: { host: "endymion", port: 40000} } }, as: :json, headers: @auth_headers
    assert_response :success 
    endpoint = Endpoint.all.last
    assert_equal "endymion", endpoint.host 
    assert_equal 40000, endpoint.port 
  end
end
