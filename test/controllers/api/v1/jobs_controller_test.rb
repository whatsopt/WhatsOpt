# frozen_string_literal: true

require "test_helper"

class Api::V1::JobsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
    @ope = operations(:doe)
  end

  test "should run a job" do
    # FIXME: does not work in github actions while it is ok locally on CentOS and Ubuntu
    # assert_enqueued_with(job: OperationJob, args: [@ope]) do
    #   OperationJob.perform_later(@ope)
    # end
    post api_v1_operation_job_url(@ope), as: :json, headers: @auth_headers
  end

  test "should kill a running job" do
    @ope.job.update(pid: "66666666", status: "RUNNING", log: "dummy job\n")
    patch api_v1_operation_job_url(@ope), as: :json, headers: @auth_headers
    job = @ope.job.reload
    assert_equal(-1, job.pid)
    assert_equal "FAILED", job.status
    assert_equal "dummy job\nProcess Aborted\n", job.log
  end
end
