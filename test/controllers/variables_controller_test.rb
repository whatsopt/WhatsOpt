require 'test_helper'

class VariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @variable = variables(:one)
  end

  test "should get index" do
    get variables_url
    assert_response :success
  end

  test "should get new" do
    get new_variable_url
    assert_response :success
  end

  test "should create variable" do
    assert_difference('Variable.count') do
      post variables_url, params: { variable: { discipline_id: @variable.discipline_id, io_mode: @variable.io_mode, name: @variable.name } }
    end

    assert_redirected_to variable_url(Variable.last)
  end

  test "should show variable" do
    get variable_url(@variable)
    assert_response :success
  end

  test "should get edit" do
    get edit_variable_url(@variable)
    assert_response :success
  end

  test "should update variable" do
    patch variable_url(@variable), params: { variable: { discipline_id: @variable.discipline_id, io_mode: @variable.io_mode, name: @variable.name } }
    assert_redirected_to variable_url(@variable)
  end

  test "should destroy variable" do
    assert_difference('Variable.count', -1) do
      delete variable_url(@variable)
    end

    assert_redirected_to variables_url
  end
end
