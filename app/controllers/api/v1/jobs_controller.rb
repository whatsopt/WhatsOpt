# frozen_string_literal: true

class Api::V1::JobsController < Api::ApiController
  before_action :set_job

  def show
    json_response @job
  end

  def create
    OperationJob.perform_later(@operation)
  end

  def update
    if @job.pid > -1
      begin
        Process.kill("KILL", @job.pid)
      rescue Exception => e
        Rails.logger.info e
      end
    end
    @job.update(pid: -1, status: "FAILED", log: @job.log << "Process Aborted\n")
  end

  private
    def set_job
      @operation = Operation.find(params[:operation_id])
      @job = @operation.job || @operation.create_job(status: "PENDING", pid: -1, log: "", log_count: 0)
      authorize @operation.analysis
    end

    def job_params
      params.require(:job).permit(:pid, :status, :log)
    end
end
