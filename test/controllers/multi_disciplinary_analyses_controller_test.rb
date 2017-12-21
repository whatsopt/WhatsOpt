require 'test_helper'

class MultiDisciplinaryAnalysesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @mda = multi_disciplinary_analyses(:cicav)
  end

  test "should get index" do
    get mdas_url
    assert_response :success
  end

  test "should get new" do
    get new_mda_url
    assert_response :success
  end

  test "should create multi_disciplinary_analysis" do
    assert_difference('MultiDisciplinaryAnalysis.count') do
      post mdas_url, params: { 
        multi_disciplinary_analysis: { name: 'test' } }
    end
    assert_redirected_to mda_url(MultiDisciplinaryAnalysis.last)
  end
  
  test "should assign owner on creation" do
    post mdas_url, params: {multi_disciplinary_analysis: { name: 'test2' } }
    assert MultiDisciplinaryAnalysis.last.owner, users(:user1)  
  end

  test "should import multi_disciplinary_analysis from excel" do
    assert_difference('MultiDisciplinaryAnalysis.count') do
      post mdas_url, params: { 
        multi_disciplinary_analysis: { attachment_attributes: {data: fixture_file_upload('excel_mda_simple_sample.xlsx') }} }
    end
    assert_redirected_to mda_url(MultiDisciplinaryAnalysis.last)
  end  

  test "should import multi_disciplinary_analysis from cmdows" do
    assert_difference('MultiDisciplinaryAnalysis.count') do
      post mdas_url, params: { 
        multi_disciplinary_analysis: { attachment_attributes: {data: fixture_file_upload('cmdows_mda_sample.cmdows') }} }
    end
    assert_redirected_to mda_url(MultiDisciplinaryAnalysis.last)
  end    
    
  test "should show multi_disciplinary_analysis" do
    get mda_url(@mda)
    assert_response :success
  end

  test "should get edit" do
    get edit_mda_url(@mda)
    assert_response :success
  end

  test "should update multi_disciplinary_analysis" do
    patch mda_url(@mda), params: { multi_disciplinary_analysis: { name: @mda.name } }
    assert_redirected_to mda_url(@mda)
  end

  test "should destroy multi_disciplinary_analysis" do
    assert_difference('MultiDisciplinaryAnalysis.count', -1) do
      delete mda_url(@mda)
    end

    assert_redirected_to mdas_url
  end

  test "should not destroy multi_disciplinary_analysis, if not owner" do
    sign_out users(:user1)
    sign_in users(:user2)
    assert_difference('MultiDisciplinaryAnalysis.count', 0) do
      delete mda_url(@mda)
    end
    assert_redirected_to root_path
    assert_equal 'You are not authorized to perform this action.', flash[:error]
  end
    
  test "should destroy discipline when destroying multi_disciplinary_analysis" do
    assert_difference('Discipline.count', -3) do  # cicav contains 3 disciplines
      delete mda_url(@mda)
    end
  end
  
  test "should destroy variables when destroying multi_disciplinary_analysis" do
    assert_difference('Variable.count', -11) do  # cicav use 11 variables
      delete mda_url(@mda)
    end
  end

end
