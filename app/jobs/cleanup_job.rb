require 'open3'

class CleanupJob < ActiveJob::Base
    
  def perform(ope, pid, sqlite_filename)
    Process.wait pid
    Rails.logger.info "Job #{pid} done"
    Rails.logger.info "Cleanup #{sqlite_filename}"
    File.delete(sqlite_filename)
    OperationRunChannel.broadcast_to(ope, status: "DONE", log: ["Data uploaded"])
  end
end
