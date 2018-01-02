require 'test_helper'

class Api::V1::DisciplineControllerTest < ActionDispatch::IntegrationTest
  setup do
    user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = multi_disciplinary_analyses(:cicav)
    @disc = @mda.disciplines.analyses.first
  end
  
  test "should get given discipline" do
    get api_v1_discipline_url(@disc), as: :json, headers: @auth_headers
    assert_response :success
  end
  
  test "should create discipline in given mda" do
    assert_difference('Discipline.count') do
      post api_v1_mda_disciplines_url(@mda), params: { discipline: { name: "TestDiscipline" } }, as: :json, headers: @auth_headers
    end
    assert_response :success
  end
  
  test "should update discipline" do
    patch api_v1_discipline_url(@disc), params: { discipline: {  name: "NewName" } }, as: :json, headers: @auth_headers
    get api_v1_discipline_url(@disc)
  end

  test "should destroy discipline" do
    assert_difference('Discipline.count', -1) do
      delete api_v1_discipline_url(@disc), as: :json, headers: @auth_headers
    end
    assert_response :success
  end
  
end
