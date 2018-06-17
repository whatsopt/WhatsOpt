require 'open3'

class OperationJob < ActiveJob::Base
    
  def perform(ope)
    ogen = WhatsOpt::OpenmdaoGenerator.new(ope.analysis, ope.host)
    OperationRunChannel.broadcast_to(ope, status: "RUNNING", log: [])
    Rails.logger.info "JOB STATUS = RUNNING"
    Dir.mktmpdir("sqlite") do |dir|
      sqlite_filename = File.join(dir, "upload.sqlite")
      ok, log = ogen.run(:analysis, sqlite_filename) 
      status = ok ? "DONE":"FAILED"
      OperationRunChannel.broadcast_to(ope, status: status, log: log)
      if ok
        # upload
        stdouterr, status = Open3.capture2e("wop", "upload",  sqlite_filename)
      end
      OperationRunChannel.broadcast_to(ope, status: status.success?, log: stdouterr)
    end
    Rails.logger.info "JOB STATUS = #{status}"
  end
end
