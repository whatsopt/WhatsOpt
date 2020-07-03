# frozen_string_literal: true

require "test_helper"

class DesignProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @cicav = analyses(:cicav)
    @singl = analyses(:singleton)
  end

  test "should get index" do
    get design_projects_url
    assert_response :success
    assert_select "tbody>tr", count: DesignProject.count
  end

  test "should create a design project" do
    assert_difference("DesignProject.count") do
      post design_projects_url, params: {
        design_project: { name: "test", description: "short project description" } }
    end
    assert_redirected_to design_projects_url
  end

  test "should assign owner on creation" do
    post design_projects_url, params: { design_project: { name: "test2" } }
    assert Analysis.last.owner, users(:user1)
  end

  test "name cannot be blank on creation" do
    post design_projects_url, params: { design_project: { name: "" } }
    assert_redirected_to new_design_project_url
  end

  test "name cannot be duplicated" do
    assert_difference("DesignProject.count") do
      post design_projects_url, params: { design_project: { name: "test" } }
      assert_redirected_to design_projects_url
    end
    assert_difference("DesignProject.count", 0) do
      post design_projects_url, params: { design_project: { name: "test" } }
      assert_redirected_to new_design_project_url
    end
  end

  test "should update design project" do
    @dp = design_projects(:cicav_project)
    put design_project_url(@dp), params: {
      design_project: { name: "test", description: "short project description" } }
    assert_redirected_to design_projects_url
  end

  test "owner should destroy design project" do
    @dp = design_projects(:cicav_project)
    assert_difference("DesignProject.count", -1) do
      delete design_project_url(@dp)
      assert_redirected_to design_projects_url
    end
  end

  test "non-owner cannot destroy design project" do
    @dp = design_projects(:cicav_project)
    sign_out users(:user1)
    user2 = users(:user2)
    sign_in user2
    assert_difference("DesignProject.count", 0) do
      delete design_project_url(@dp)
    end
  end
end
