class OperationJob < ActiveJob::Base
  
  def perform(user, ope)
    ogen = WhatsOpt::OpenmdaoGenerator.new(ope.analysis, ope.host)
    OperationRunChannel.broadcast_to(ope, status: "RUNNING", log: [])
    Rails.logger.info "JOB STATUS = RUNNING"

    sqlite_filename = File.join(Dir.tmpdir, "#{SecureRandom.urlsafe_base64}.sqlite")
    Rails.logger.info sqlite_filename
    
    Dir.mktmpdir("sqlite") do |dir|
      ok, log = ogen.run(ope.category, sqlite_filename) 
      if ok
        if ope.driver == "runonce"
          OperationRunChannel.broadcast_to(ope, status: "DONE", log: log)
          Rails.logger.info "JOB STATUS = DONE"          
        else
          # upload
          UploadJob.perform_later(user, ope, sqlite_filename)
        end 
      else
        OperationRunChannel.broadcast_to(ope, status: "FAILED", log: log)
        Rails.logger.info "JOB STATUS = FAILED"
      end
    end
  end
end
