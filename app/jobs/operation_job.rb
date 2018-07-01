class OperationJob < ActiveJob::Base
  
  def perform(user, ope)
    ogen = WhatsOpt::OpenmdaoGenerator.new(ope.analysis, ope.host)
    Rails.logger.info "JOB STATUS = RUNNING"
    job = ope.job
    job.update(status: :RUNNING, log: "")

    sqlite_filename = File.join(Dir.tmpdir, "#{SecureRandom.urlsafe_base64}.sqlite")
    Rails.logger.info sqlite_filename
    
    Dir.mktmpdir("sqlite") do |dir|
      status = ogen.monitor(ope.category, sqlite_filename) do |stdin, stdouterr, wait_thr|
        job.update(status: :RUNNING, pid: wait_thr.pid)
        stdin.close
        lines = []
        while line = stdouterr.gets
          job.update_column(:log, job.log << line)
        end
        wait_thr.value
      end
      if File.exists?(sqlite_filename)
        puts "FILE #{sqlite_filename} EXISTS"
      else
        puts "FILE #{sqlite_filename} DO NOOOOOOOOOOOOOT EXISTS"        
      end
      if status.success?
        if ope.driver == "runonce"
          Rails.logger.info "JOB STATUS = DONE"          
          job.update(status: :DONE)
        else
          # upload
          #UploadJob.perform_later(user, ope, sqlite_filename)
          _upload(user, ope, sqlite_filename)
        end 
      else
        Rails.logger.info "JOB STATUS = FAILED"
        job.update(status: :FAILED)
      end
      Rails.logger.info job.log
    end
  end
  
  def _upload(user, ope, sqlite_filename)
    Rails.logger.info "About to load #{sqlite_filename}"
    if (File.exists?(sqlite_filename))
      Rails.logger.info "Upload data #{sqlite_filename}"
      pid = Process.spawn("wop", "--credentials", user.api_key, 
                          "upload", sqlite_filename, 
                          "--operation-id", ope.id.to_s) 
      Rails.logger.info "Data #{sqlite_filename} uploaded via wop upload (PID=#{pid})"
      # delay to avoid deadlock
      _cleanup(ope, pid, sqlite_filename)
      #CleanupJob.perform_later(ope, pid, sqlite_filename)
    else 
      Rails.logger.warn "#{sqlite_filename} DOES NOT EXIST"
    end
  end
  
  def _cleanup(ope, pid, sqlite_filename)
    Process.wait pid
    Rails.logger.info "Job #{pid} done"
    Rails.logger.info "Cleanup #{sqlite_filename}"
    File.delete(sqlite_filename)
    ope.job.update(status: 'DONE', log: ope.job.log << "Data uploaded\n" )
  end
end
