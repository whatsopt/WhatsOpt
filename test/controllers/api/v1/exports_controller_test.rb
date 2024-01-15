# frozen_string_literal: true

require "test_helper"

class Api::V1::ExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  test "should pull nested analysis as openmdao code" do
    mda = analyses(:outermda)
    get api_v1_mda_exports_new_url(mda, format: :openmdao), as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should pull nested analysis as openmdao code package" do
    mda = analyses(:outermda)
    get api_v1_mda_exports_new_url(mda, format: :openmdao_pkg), as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should not pull nested analysis as gemseo code but return an error" do
    mda = analyses(:outermda)
    get api_v1_mda_exports_new_url(mda, format: :gemseo), as: :json, headers: @auth_headers
    assert_response :bad_request
  end

  test "should dump analysis as egmdo method code" do
    mda = analyses(:cicav)
    get api_v1_mda_exports_new_url(mda, format: :openmdao, with_egmdo: "true"), as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should not pull a private analysis if not owner" do
    # owned by user2
    mda = analyses(:fast)
    get api_v1_mda_exports_new_url(mda, format: :openmdao_pkg), as: :json, headers: @auth_headers
    assert_response :unauthorized
  end

  test "should fetch packaged content from src_mda in current mda" do
    mda = analyses(:cicav)
    src_mda = analyses(:singleton)
    # XXX: Fixture does not seem to always load the file properly
    #      this ensure the presence of the file and avoid tar extraction error
    src_mda.package.archive.attach(io: File.open(file_fixture("singleton-0.1.0.tar.gz")), filename: "singleton-0.1.0.tar.gz")
    get api_v1_mda_exports_new_url(mda, format: :mda_pkg_content, src_id: src_mda), as: :json, headers: @auth_headers
    assert_response :success
  end
end
