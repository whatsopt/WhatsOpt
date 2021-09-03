# frozen_string_literal: true

require "test_helper"

class Api::V1::DesignProjectsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "should get an empty design project" do
    @proj = design_projects(:empty_project)
    get api_v1_design_project_url(@proj), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal [], resp["analyses_attributes"]
  end

  test "should get design project" do
    @proj = design_projects(:cicav_project)
    get api_v1_design_project_url(@proj), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 3, resp["analyses_attributes"].size
  end

  test "should create a project with its analyses" do
    @proj = design_projects(:cicav_project)
    get api_v1_design_project_url(@proj), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    resp["name"] = "#{resp["name"]}_duplicate"
    assert_difference("DesignProject.count") do
      assert_difference("Analysis.count", 3) do
        post api_v1_design_projects_url, as: :json, headers: @auth_headers, params: {project: resp}
        assert_response :success
      end
    end
  end

  test "should create a project with nested analyses" do
    @proj = design_projects(:nested_mda_project)
    get api_v1_design_project_url(@proj), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    resp["name"] = "#{resp["name"]}_duplicate"
    assert_difference("DesignProject.count") do
      assert_difference("Analysis.count", 2) do
        post api_v1_design_projects_url, as: :json, headers: @auth_headers, params: {project: resp}
        assert_response :success
      end
    end
  end

end