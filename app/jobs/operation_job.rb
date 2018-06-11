class OperationJob < ActiveJob::Base
  
  def perform(mda, mda_server_host)
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda, mda_server_host)
    ok, log = ogen.run :analysis
    Rails.logger.info "JOB STATUS_OK = #{ok}"
    Rails.logger.info "JOB LOGS = #{log}"
  end
end
