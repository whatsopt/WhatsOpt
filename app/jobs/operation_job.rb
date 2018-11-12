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
        job.update(status: :RUNNING, sqlite_filename: sqlite_filename, pid: wait_thr.pid)
        stdin.close
        lines = []
        while line = stdouterr.gets
          job.update_column(:log, job.log << line)
        end
        wait_thr.value
      end
      ope.update_on_termination
      # Rails.logger.info job.log
    end
  end

end
