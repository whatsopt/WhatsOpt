require 'test_helper'

class Api::V1::AnalysisDisciplinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    sign_in user1
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @outermda = analyses(:outermda)
    @innermda = analyses(:innermda)
    @cicav = analyses(:cicav)
    @innermdadisc = disciplines(:outermda_innermda_discipline)
    @vacantdisc = disciplines(:outermda_vacant_discipline)
  end

  test "should create an analysis discipline from a given analysis" do
    assert_difference('AnalysisDiscipline.count') do
      assert_difference('Discipline.count') do
        post api_v1_mda_discipline_url(@outermda), params: { analysis_discipline: {analysis_id: @cicav.id }}, 
          as: :json, headers: @auth_headers
        assert_response :success
      end
    end
  end
  
  test "should create an analysis discipline from a given discipline and an analysis" do
    assert_difference('AnalysisDiscipline.count') do
      post api_v1_discipline_mda_url(@vacantdisc), params: { analysis_discipline: {analysis_id: @cicav.id }}, 
        as: :json, headers: @auth_headers
      assert_response :success
    end
  end

  test "should delete an mda discipline" do
    assert_difference('AnalysisDiscipline.count', -1) do
      delete api_v1_discipline_mda_url(@innermdadisc), as: :json, headers: @auth_headers
      assert_response :success
    end
  end

    
end
