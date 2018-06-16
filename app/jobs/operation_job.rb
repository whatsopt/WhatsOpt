class OperationJob < ActiveJob::Base
  
  def perform(ope)
    ogen = WhatsOpt::OpenmdaoGenerator.new(ope.analysis, ope.host)
    OperationRunChannel.broadcast_to(ope, status: "RUNNING", log: [])
    Rails.logger.info "JOB STATUS = RUNNING"
    ok, log = ogen.run :analysis
    status = ok ? "DONE":"FAILED"
    OperationRunChannel.broadcast_to(ope, status: status, log: log)
    Rails.logger.info "JOB STATUS = #{status}"
  end
end
