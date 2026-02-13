# frozen_string_literal: true

require "test_helper"

class Api::V1::DesignProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @auth_headers2 = { "Authorization" => "Token " + TEST_API_KEY + "User2" }
  end

  test "should get an empty design project" do
    @proj = design_projects(:empty_project)
    get api_v1_design_project_url(@proj), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_nil resp["analyses_attributes"]
    assert_equal [], resp["analyses"]
  end

  test "should get a design project" do
    @proj = design_projects(:cicav_project)
    get api_v1_design_project_url(@proj), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_nil resp["analyses_attributes"]
    assert_equal 1, resp["analyses"].size
  end

  test "should get design project in wopjson" do
    @proj = design_projects(:cicav_project)
    get api_v1_design_project_url(@proj, format: :wopjson), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 1, resp["analyses_attributes"].size
  end

  test "should not get a project as wopjson when not owner" do
    @proj = design_projects(:cicav_project)
    get api_v1_design_project_url(@proj, format: :wopjson), as: :json, headers: @auth_headers2
    assert_response :unauthorized
  end

  test "should create a project with its analyses" do
    @proj = design_projects(:cicav_project)
    get api_v1_design_project_url(@proj, format: :wopjson), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    resp["name"] = "#{resp["name"]}_duplicate"
    assert_difference("DesignProject.count") do
      assert_difference("Analysis.count", 1) do
        post api_v1_design_projects_url, as: :json, headers: @auth_headers, params: { project: resp }
        assert_response :success
      end
    end
    proj = DesignProject.last
    assert_equal 1, proj.analyses.count
  end

  test "should create a project with nested analyses" do
    @proj = design_projects(:nested_mda_project)
    get api_v1_design_project_url(@proj, format: :wopjson), as: :json, headers: @auth_headers2
    assert_response :success
    resp = JSON.parse(response.body)
    resp["name"] = "#{resp["name"]}_duplicate"
    assert_difference("DesignProject.count") do
      assert_difference("Analysis.count", 2) do
        post api_v1_design_projects_url, as: :json, headers: @auth_headers2, params: { project: resp }
        assert_response :success
      end
    end
    proj = DesignProject.last
    assert_equal 1, proj.analyses.count   # the sub analyse innermda not attached to a project
  end
end
