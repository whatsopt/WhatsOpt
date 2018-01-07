require 'test_helper'

class AnalysesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @mda = analyses(:cicav)
  end

  test "should get index" do
    get mdas_url
    assert_response :success
  end

  test "should get new" do
    get new_mda_url
    assert_response :success
  end

  test "should create analysis" do
    assert_difference('Analysis.count') do
      post mdas_url, params: { 
        analysis: { name: 'test' } }
    end
    assert_redirected_to mda_url(Analysis.last)
  end
  
  test "should assign owner on creation" do
    post mdas_url, params: {analysis: { name: 'test2' } }
    assert Analysis.last.owner, users(:user1)  
  end

  test "should import analysis from excel" do
    assert_difference('Analysis.count') do
      post mdas_url, params: { 
        analysis: { attachment_attributes: {data: fixture_file_upload('excel_mda_simple_sample.xlsx') }} }
    end
    assert_redirected_to mda_url(Analysis.last)
  end  

  test "should import analysis from cmdows" do
    assert_difference('Analysis.count') do
      post mdas_url, params: { 
        analysis: { attachment_attributes: {data: fixture_file_upload('cmdows_mda_sample.cmdows') }} }
    end
    assert_redirected_to mda_url(Analysis.last)
  end    
    
  test "should show analysis" do
    get mda_url(@mda)
    assert_response :success
  end

  test "should get edit" do
    get edit_mda_url(@mda)
    assert_response :success
  end

  test "should update analysis" do
    patch mda_url(@mda), params: { analysis: { name: @mda.name } }
    assert_redirected_to mda_url(@mda)
  end

  test "should destroy analysis" do
    assert_difference('Analysis.count', -1) do
      delete mda_url(@mda)
    end

    assert_redirected_to mdas_url
  end

  test "should not destroy analysis, if not owner" do
    sign_out users(:user1)
    sign_in users(:user2)
    assert_difference('Analysis.count', 0) do
      delete mda_url(@mda)
    end
    assert_redirected_to root_path
    assert_equal 'You are not authorized to perform this action.', flash[:error]
  end
    
  test "should destroy discipline when destroying analysis" do
    assert_difference('Discipline.count', -3) do  # cicav contains 3 disciplines
      delete mda_url(@mda)
    end
  end
  
  test "should destroy variables when destroying analysis" do
    assert_difference('Variable.count', -11) do  # cicav use 11 variables
      delete mda_url(@mda)
    end
  end

end
