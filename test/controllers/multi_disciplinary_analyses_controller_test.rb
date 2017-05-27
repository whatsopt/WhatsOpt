require 'test_helper'

class MultiDisciplinaryAnalysesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @multi_disciplinary_analysis = multi_disciplinary_analyses(:cicav)
  end

  test "should get index" do
    get multi_disciplinary_analyses_url
    assert_response :success
  end

  test "should get new" do
    get new_multi_disciplinary_analysis_url
    assert_response :success
  end

  test "should create multi_disciplinary_analysis" do
    assert_difference('MultiDisciplinaryAnalysis.count') do
      post multi_disciplinary_analyses_url, params: { 
        multi_disciplinary_analysis: { name: @multi_disciplinary_analysis.name } }
    end

    assert_redirected_to multi_disciplinary_analysis_url(MultiDisciplinaryAnalysis.last)
  end

  test "should import multi_disciplinary_analysis" do
    assert_difference('MultiDisciplinaryAnalysis.count') do
      post multi_disciplinary_analyses_url, params: { 
        multi_disciplinary_analysis: { attachment_attributes: {data: fixture_file_upload('excel_mda_simple_sample.xlsm') }} }
    end

    assert_redirected_to multi_disciplinary_analysis_url(MultiDisciplinaryAnalysis.last)
  end  
  
  test "should show multi_disciplinary_analysis" do
    get multi_disciplinary_analysis_url(@multi_disciplinary_analysis)
    assert_response :success
  end

  test "should get edit" do
    get edit_multi_disciplinary_analysis_url(@multi_disciplinary_analysis)
    assert_response :success
  end

  test "should update multi_disciplinary_analysis" do
    patch multi_disciplinary_analysis_url(@multi_disciplinary_analysis), params: { multi_disciplinary_analysis: { name: @multi_disciplinary_analysis.name } }
    assert_redirected_to multi_disciplinary_analysis_url(@multi_disciplinary_analysis)
  end

  test "should destroy multi_disciplinary_analysis" do
    assert_difference('MultiDisciplinaryAnalysis.count', -1) do
      delete multi_disciplinary_analysis_url(@multi_disciplinary_analysis)
    end

    assert_redirected_to multi_disciplinary_analyses_url
  end
end
