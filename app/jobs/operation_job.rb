require 'socket'
require 'whats_opt/sqlite_case_importer'

class OperationJob < ActiveJob::Base
  
  WOP_CMD = APP_CONFIG['wop_cmd'] || wop
  WOP_ENV = APP_CONFIG['wop_env'] || {}
  
  def perform(user, ope)
    ogen = WhatsOpt::OpenmdaoGenerator.new(ope.analysis, ope.host, ope.driver, ope.option_hash)
    Rails.logger.info "JOB STATUS = RUNNING"
    job = ope.job || ope.create_job(status: 'PENDING', pid: -1, log: "")
    job.update(status: :RUNNING, started_at: Time.now, ended_at: nil, log: "")

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
      if status.success?
        if ope.driver == "runonce"
          Rails.logger.info "JOB STATUS = DONE"          
          job.update(status: :DONE)
          ope.update(cases: [])
        else
          # upload
          _upload(user, ope, sqlite_filename)
        end 
      else
        Rails.logger.info "JOB STATUS = FAILED"
        job.update(status: :FAILED, ended_at: Time.now)
      end
      # Rails.logger.info job.log
    end
  end
  
  def _upload(user, ope, sqlite_filename)
    Rails.logger.info "About to load #{sqlite_filename}"
    importer = WhatsOpt::SqliteCaseImporter.new(sqlite_filename)
    operation_params = {cases: importer.cases_attributes}
    ope.update_operation(operation_params)
    ope.save!
    #ope.set_upload_job_done
    #Rails.logger.info "Cleanup #{sqlite_filename}"
    Rails.logger.info "Cleanup DISABLED"
    #File.delete(sqlite_filename)
  end

end
