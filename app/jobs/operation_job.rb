class OperationJob < ActiveJob::Base
  
  def perform(user, ope)
    ogen = WhatsOpt::OpenmdaoGenerator.new(ope.analysis, ope.host)
    Rails.logger.info "JOB STATUS = RUNNING"
    job = ope.create_job(status: :RUNNING, log: "")

    sqlite_filename = File.join(Dir.tmpdir, "#{SecureRandom.urlsafe_base64}.sqlite")
    Rails.logger.info sqlite_filename
    
    Dir.mktmpdir("sqlite") do |dir|
      status = ogen.monitor(ope.category, sqlite_filename) do |stdin, stdouterr, wait_thr|
        job.update(status: :RUNNING, pid: wait_thr.pid)
        stdin.close
        lines = []
        while line = stdouterr.gets('\n')
          job.update(log: job.log << line)
        end
        wait_thr.value
      end
      if status.success?
        if ope.driver == "runonce"
          Rails.logger.info "JOB STATUS = DONE"          
          job.update(status: :DONE)
        else
          # upload
          UploadJob.perform_later(user, ope, sqlite_filename)
        end 
      else
        Rails.logger.info "JOB STATUS = FAILED"
        job.update(status: :FAILED)
      end
      Rails.logger.info job.log
    end
  end
end
