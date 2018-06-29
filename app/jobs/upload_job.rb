require 'open3'

class UploadJob < ActiveJob::Base
    
  def perform(user, ope, sqlite_filename)
    Rails.logger.info "About to load #{sqlite_filename}"
    if (File.exists?(sqlite_filename))
      Rails.logger.info "Upload data #{sqlite_filename}"
      pid = Process.spawn("wop", "--credentials", user.api_key, 
                          "upload", sqlite_filename, 
                          "--operation-id", ope.id.to_s) 
      Rails.logger.info "Data #{sqlite_filename} uploaded via wop upload (PID=#{pid})"
      # delay to avoid deadlock
      CleanupJob.set(wait: 5.seconds).perform_later(ope, pid, sqlite_filename)
    else 
      Rails.logger.warn "#{sqlite_filename} DOES NOT EXIST"
    end
  end
end
