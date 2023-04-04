# frozen_string_literal: true

require "test_helper"

class Api::V1::PackagesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
  end

  test "should create package" do
    assert_difference("Package.count", 1) do
      post api_v1_mda_package_url(@mda), params: { package: { 
              archive: fixture_file_upload(sample_file("my_sellar-0.1.0.tar.gz"), 'application/tar+gzip'),
              description: "This a package" 
            }}, as: :json, headers: @auth_headers
      assert_response :success
      p response.body
    end
    pack = Package.last
    p pack
    p pack.archive.attached?
  end

end
