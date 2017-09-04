require 'test_helper'

class DisciplinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @discipline = disciplines(:geometry)
  end

  test "should get index" do
    get disciplines_url
    assert_response :success
  end

  test "should get new" do
    get new_discipline_url
    assert_response :success
  end

  test "should create discipline" do
    assert_difference('Discipline.count') do
      post disciplines_url, params: { discipline: { multi_disciplinary_analysis_id: @discipline.multi_disciplinary_analysis_id, name: @discipline.name } }
    end

    assert_redirected_to discipline_url(Discipline.last)
  end

  test "should show discipline" do
    get discipline_url(@discipline)
    assert_response :success
  end

  test "should get edit" do
    get edit_discipline_url(@discipline)
    assert_response :success
  end

  test "should update discipline" do
    patch discipline_url(@discipline), params: { discipline: { multi_disciplinary_analysis_id: @discipline.multi_disciplinary_analysis_id, name: @discipline.name } }
    assert_redirected_to discipline_url(@discipline)
  end

  test "should destroy discipline" do
    assert_difference('Discipline.count', -1) do
      delete discipline_url(@discipline)
    end

    assert_redirected_to disciplines_url
  end
end
