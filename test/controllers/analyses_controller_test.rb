# frozen_string_literal: true

require "test_helper"

class AnalysesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:user1)
    sign_in @user1
    @cicav = analyses(:cicav)
    @singl = analyses(:singleton)
  end

  test "should get index" do
    get mdas_url
    assert_response :success
    assert_select "tbody>tr", count: Analysis.count - 2 # all - (1 sub analysis + 1 user2 private)
  end

  test "should get my analyses" do
    @user1.analyses_query = "mine"
    @user1.save!
    get mdas_url
    assert_response :success
    assert_select "tbody>tr", count: Analysis.roots.owned_by(@user1).size
  end

  test "should get analyses by project" do
    project = design_projects(:cicav_project)
    get mdas_url(design_project_id: project.id)
    assert_redirected_to mdas_url
    get mdas_url
    assert_select "tbody>tr", count: 3
  end

  test "should get new" do
    get new_mda_url
    assert_response :success
  end

  test "should create analysis" do
    assert_difference("Analysis.count") do
      post mdas_url, params: {
        analysis: { name: "test" } }
    end
    assert_redirected_to edit_mda_url(Analysis.last)
  end

  test "should assign owner on creation" do
    post mdas_url, params: { analysis: { name: "test2" } }
    assert Analysis.last.owner, users(:user1)
  end

  test "should authorized access by default" do
    post mdas_url, params: { analysis: { name: "test2" } }
    sign_out users(:user1)
    sign_in users(:user2)
    get mda_url(Analysis.last)
    assert_response :success
    # assert_redirected_to root_path
  end

  test "should authorized access if public attr is set" do
    post mdas_url, params: { analysis: { name: "test2", public: true } }
    sign_out users(:user1)
    sign_in users(:user2)
    get mda_url(Analysis.last)
    assert_response :success
  end
  
  test "should authorized access to members" do
    sign_in users(:user3)
    get mda_url(@cicav)
    assert_response :success
  end

  test "should show analysis" do
    get mda_url(@cicav)
    assert_response :success
  end

  test "should get edit" do
    get edit_mda_url(@cicav)
    assert_response :success
  end

  test "should destroy analysis" do
    sign_out users(:user1)
    sign_in users(:user3)
    assert_difference("Analysis.count", -1) do
      delete mda_url(@singl)
    end
    assert_redirected_to mdas_url
    assert_not flash[:alert]
  end

  test "should not destroy analysis if nested" do
    assert_difference("Analysis.count", 0) do
      delete mda_url(analyses(:innermda))
    end
    assert_redirected_to mdas_url
    assert_match(/Can not delete nested analysis/, flash[:alert])
  end

  test "should destroy analysis and operation" do
    nb_ops = @cicav.operations.count
    assert_difference("Analysis.count", -1) do
      assert_difference("Operation.count", -nb_ops) do
        delete mda_url(@cicav)
      end
    end
    assert_redirected_to mdas_url
  end

  test "should not destroy analysis, if not owner" do
    assert_difference("Analysis.count", 0) do
      delete mda_url(@singl)
    end
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:error]
  end

  test "should destroy discipline when destroying analysis" do
    sign_out users(:user1)
    sign_in users(:user3)
    q = @singl.disciplines
    assert_difference("Discipline.count", -q.count) do
      delete mda_url(@singl)
    end
  end

  test "should destroy variables when destroying analysis" do
    sign_out users(:user1)
    sign_in users(:user3)
    q = Variable.joins(discipline: :analysis).where(analyses: { id: @singl.id })
    assert_difference("Variable.count", -q.count) do
      delete mda_url(@singl)
    end
  end

  test "should destroy connections when destroying analysis" do
    sign_out users(:user1)
    sign_in users(:user3)
    q = Connection.of_analysis(@singl.id)
    assert_difference("Connection.count", -q.count) do
      delete mda_url(@singl)
    end
  end

  test "should destroy sub-analysis when destroying parent" do
    @outermda = analyses(:outermda)
    assert_difference("Analysis.count", -2) do
      delete mda_url(@outermda)
    end
  end

  test "should make a copy of an analysis" do
    user1 = users(:user1)
    user2 = users(:user2)
    user3 = users(:user3)
    sign_out user1
    sign_in user2
    assert_difference("Analysis.count") do
      post mdas_url, params: { mda_id: @cicav.id }
      assert_redirected_to mda_url(Analysis.last)
    end
    copy =  Analysis.last
    assert_equal @cicav.disciplines.count, copy.disciplines.count

    assert_equal user2, copy.owner
    assert_equal @cicav.public, copy.public
    assert_equal @cicav.locked, copy.locked
    assert_equal @cicav.design_project, copy.design_project
    assert_equal [], copy.members  # cicav public
  end

  test "should make a copy of a nested analysis" do
    sign_out users(:user1)
    user2 = users(:user2)
    sign_in user2
    @outermda = analyses(:outermda)
    assert_difference("AnalysisDiscipline.count", 1) do
      assert_difference("Analysis.count", 2) do
        post mdas_url, params: { mda_id: @outermda.id }
        assert_redirected_to mda_url(Analysis.second_to_last)
      end
    end
    copy_outer = Analysis.second_to_last
    copy_inner = Analysis.last
    assert copy_outer.disciplines.third.has_sub_analysis?
    assert_equal @outermda.disciplines.count, copy_outer.disciplines.count
    assert_equal user2, copy_outer.owner
    assert_equal user2, copy_inner.owner
  end
end
