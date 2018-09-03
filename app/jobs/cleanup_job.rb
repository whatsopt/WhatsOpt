require 'open3'

class CleanupJob < ActiveJob::Base
    
  def perform(ope, pid, sqlite_filename)
    Rails.logger.info "Waiting for job #{pid} termination"
    _, status = Process.wait2 pid
    Rails.logger.info "Job #{pid} terminated exitstatus=#{status}"
    Rails.logger.info "Cleanup #{sqlite_filename}"
    File.delete(sqlite_filename)
  end
end
