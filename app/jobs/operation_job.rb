class OperationJob < ActiveJob::Base
  
  def perform(user, ope)
    ogen = WhatsOpt::OpenmdaoGenerator.new(ope.analysis, ope.host)
    OperationRunChannel.broadcast_to(ope, status: "RUNNING", log: [])
    Rails.logger.info "JOB STATUS = RUNNING"

    sqlite_filename = File.join(Dir.tmpdir, "#{SecureRandom.urlsafe_base64}.sqlite")
    Rails.logger.info sqlite_filename
    
    Dir.mktmpdir("sqlite") do |dir|
      ok, log = ogen.run(ope.category, sqlite_filename) 
      state = ok ? "DONE":"FAILED"
      OperationRunChannel.broadcast_to(ope, status: state, log: log)
      if ok
        # upload
        UploadJob.perform_later(user, ope, sqlite_filename) 
      end
      Rails.logger.info "JOB STATUS = #{state}"
    end
  end
end
