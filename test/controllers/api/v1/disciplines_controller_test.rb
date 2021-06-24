# frozen_string_literal: true

require "test_helper"

class Api::V1::DisciplineControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
    @disc = disciplines(:geometry)
    @disc2 = disciplines(:aerodynamics)
    @submda = analyses(:singleton)
    @submda2 = analyses(:sub_analysis)
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
      post api_v1_mda_disciplines_url(@mda), params: { 
        discipline: { name: "TestDiscipline", type: "analysis" 
      } }, as: :json, headers: @auth_headers
    end
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal "TestDiscipline", resp["name"]
    assert_equal @mda.id, Discipline.last.analysis.id
  end

  test "should update a discipline with sub analysis" do
    assert_difference("Discipline.count", 0) do
      assert_difference("AnalysisDiscipline.count") do
        put api_v1_discipline_url(@disc), params: { 
          discipline: { name: "TestDiscipline", type: "mda",
                        analysis_discipline_attributes: { discipline_id: @disc.id, analysis_id: @submda.id }
          } }, as: :json, headers: @auth_headers
      end
    end
    assert_response :success
    assert @disc.sub_analysis
    @disc.reload
  end

  test "should prevent a sub_analysis with same output" do
    post api_v1_mda_disciplines_url(@mda), params: { 
      discipline: { name: "TestDiscipline", type: "analysis" 
    } }, as: :json, headers: @auth_headers
    assert_response :success
    disc = Discipline.last
    assert_difference("Discipline.count", 0) do
      assert_difference("AnalysisDiscipline.count", 0) do
        put api_v1_discipline_url(disc), params: { 
          discipline: { name: "TestDiscipline", type: "mda",
                        analysis_discipline_attributes: { discipline_id: disc.id, analysis_id: @submda2.id }
          } }, as: :json, headers: @auth_headers
      end
    end
    assert_response :unprocessable_entity
  end

  test "should prevent a sub_analysis discipline without analysis" do
    assert_difference("AnalysisDiscipline.count", 0) do
      put api_v1_discipline_url(@disc), params: { 
        discipline: { name: "TestDiscipline", type: "mda",
                      analysis_discipline_attributes: { discipline_id: @disc.id, analysis_id: nil }
        } }, as: :json, headers: @auth_headers
    end
    assert_response :not_found
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
    @disc.reload
    assert_equal 2, @disc.position
    @disc2.reload
    assert_equal 1, @disc2.position
  end

  test "should delete discipline and related variables" do
    initial_drivervar_count = @disc.analysis.driver.variables.count
    assert_difference("Discipline.count", -1) do
      delete api_v1_discipline_url(@disc), as: :json, headers: @auth_headers
      assert_response :success
      vars = @disc.analysis.driver.variables.reload.map(&:name)
      drivervar_count = vars.size
      assert_equal initial_drivervar_count, drivervar_count
    end
  end

  test "should delete connections in parent analysis" do
    @disc = disciplines(:innermda_discipline)
    @innermda = @disc.analysis
    @outermda = @disc.analysis.parent
    initial_drivervars = @outermda.driver.variables.map(&:name)
    assert_difference("Discipline.count", -1) do
      delete api_v1_discipline_url(@disc), as: :json, headers: @auth_headers
      assert_response :success
      # should have suppressed connection to y and driver y variable because only used by deleted disc in innermda
      # should have suppressed connection to x2 and driver x2 variable because only used by deleted disc in innermda
      @outermda.driver.reload.variables.map(&:name)
      assert_equal initial_drivervars - ["x2", "y"], @outermda.driver.reload.variables.map(&:name)
    end
  end

  test "should update discipline with an endpoint" do
    patch api_v1_discipline_url(@disc), params: { discipline: { endpoint_attributes: { host: "endymion", port: 40000 } } }, as: :json, headers: @auth_headers
    assert_response :success
    endpoint = Endpoint.all.last
    assert_equal "endymion", endpoint.host
    assert_equal 40000, endpoint.port
  end

  test "should not delete analysis when destroyed as an analysis discipline" do
    @disc = disciplines(:outermda_innermda_discipline)
    assert_difference("Analysis.count", 0) do
      assert_difference("Discipline.count", -1) do
        assert_difference("AnalysisDiscipline.count", -1) do
          innermda = @disc.sub_analysis
          delete api_v1_discipline_url(@disc), as: :json, headers: @auth_headers
          assert innermda.reload.is_root_analysis?
        end
      end
    end
  end
end
