require 'open3'

class UploadJob < ActiveJob::Base
    
  def perform(ope_id, sqlite_filename)
    # upload
    puts "ABOUT to load #{sqlite_filename}"
    if (File.exists?(sqlite_filename))
      ope = Operation.find(ope_id)
      Rails.logger.info "Upload data #{sqlite_filename}"
      pid = Process.spawn("wop", "upload", sqlite_filename, "--analysis-id", ope.analysis.id.to_s) 
      Rails.logger.info "Data #{sqlite_filename} uploaded via wop upload (PID=#{pid})"
    else 
      Rails.logger.info "#{sqlite_filename} DOES NOT EXIST"
    end
  end
end
