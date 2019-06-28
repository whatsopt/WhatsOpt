# frozen_string_literal: true

require "socket"
require "whats_opt/openmdao_generator"
require "whats_opt/sqlite_case_importer"

class Operation < ApplicationRecord
  CAT_RUNONCE = :analysis
  CAT_OPTIMISATION = :optimization
  CAT_SCREENING = :screening
  CAT_DOE = :doe
  CATEGORIES = [CAT_RUNONCE, CAT_OPTIMISATION, CAT_DOE, CAT_SCREENING].freeze

  BATCH_COUNT = 10 # nb of log lines processed together
  LOGDIR = File.join(Rails.root, "upload/logs")

  belongs_to :analysis
  has_many :options, dependent: :destroy
  accepts_nested_attributes_for :options, reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true

  has_many :cases, dependent: :destroy
  has_one :job, dependent: :destroy

  validates :name, presence: true, allow_blank: false
  validate :success_flags_consistent_with_cases

  scope :in_progress, ->(analysis) { Operation.where(analysis: analysis).left_outer_joins(:cases).where(cases: { operation_id: nil }) }
  scope :done, ->(analysis) { Operation.where(analysis: analysis).left_outer_joins(:cases).where.not(cases: { operation_id: nil }).uniq }

  serialize :success, Array

  def success_flags_consistent_with_cases
    if (cases.blank? && !success.blank?) || (!cases.blank? && (cases[0].values.size != success.size))
      errors.add(:success, "size (#{success.size}) can not be different from cases values size (#{cases.blank? ? 0 : cases[0].values.size})")
    end
  end

  def self.build_operation(mda, ope_attrs)
    operation = mda.operations.build(ope_attrs.except(:cases))
    operation._build_cases(ope_attrs[:cases]) if ope_attrs[:cases]
    if ope_attrs[:cases]
      operation.build_job(status: "DONE", log: "")
    else
      operation.build_job(status: "PENDING", log: "")
    end
    operation
  end

  def to_plotter_json
    adapter = ActiveModelSerializers::SerializableResource.new(self)
    adapter.to_json
  end

  def category
    case driver
    when "runonce"
      "analysis"
    when /optimizer/, /slsqp/, /scipy/, /pyoptsparse/
      "optimization"
    when /morris/, /sobol/
      "screening"
    when /doe/, /lhs/
      "doe"
    else
      if !analysis.objective_variables.empty?
        "optimization"
      else
        "doe"
      end
    end
   end

  def nb_of_points
    cases[0]&.nb_of_points || 0
  end

  def option_hash
    options.map { |h| [h["name"].to_sym, h["value"]] }.to_h
  end

  def update_operation(ope_attrs)
    ope_attrs[:options_attributes]&.each do |opt|
      opt[:value] = opt[:value].to_s
    end
    update(ope_attrs.except(:cases))
    if ope_attrs[:cases]
      _update_cases(ope_attrs[:cases])
      _set_upload_job_done
    end
  end

  def input_cases
    cases.select { |c| c.variable.is_connected_as_input_of_interest? }
  end

  def output_cases
    cases.select { |c| c.variable.is_connected_as_output_of_interest? }
  end

  def perform
    ogen = WhatsOpt::OpenmdaoGenerator.new(analysis, host, driver, option_hash)
    sqlite_filename = File.join(Dir.tmpdir, "#{SecureRandom.urlsafe_base64}.sqlite")
    tmplog_filename = File.join(Dir.tmpdir, "#{SecureRandom.urlsafe_base64}.log")
    FileUtils.touch(tmplog_filename) # ensure logfile existence
    Rails.logger.info sqlite_filename
    job = self.job || create_job
    job.update(status: "RUNNING", sqlite_filename: sqlite_filename,
               started_at: Time.now, ended_at: nil, log: "", log_count: 0)

    Dir.mktmpdir("sqlite") do |_dir|
      lines = ""
      count = 0
      status = ogen.monitor(category, sqlite_filename) do |stdin, stdouterr, wait_thr|
        Rails.logger.info "JOB STATUS = RUNNING"
        job.update(status: :RUNNING, pid: wait_thr.pid)
        stdin.close
        dump_count = 0
        while line = stdouterr.gets
          lines << line
          count += 1
          next unless count % BATCH_COUNT == 0

          puts "COUNT = #{count}"
          puts "DUMP COUNT = #{dump_count}"
          puts "LOG COUNT = #{job.log_count}"
          if dump_count < 10 * BATCH_COUNT
            dump_count += BATCH_COUNT
          else
            File.open(tmplog_filename, "a") { |f| f << job.log }
            dump_count = 0
          end
          if count > 10 * BATCH_COUNT
            log_shift = job.log
            (1..10).each { |_i| log_shift = log_shift[log_shift.index("\n") + 1..-1] }
            job.update_columns(log: log_shift << lines, log_count: count)
          else
            job.update_columns(log: job.log << lines, log_count: count)
          end
          lines = ""
        end
        wait_thr.value
      end
      job.update_columns(log: job.log << lines, log_count: count)
      File.open(tmplog_filename, "a") { |f| f << job.log }
      Rails.logger.info "Log line count = #{job.log_count}"
      _update_on_termination(status)
    end
    logfile = File.join(LOGDIR, "ope_#{id}.log")
    FileUtils.copy(tmplog_filename, logfile)
  end

  def _update_on_termination(status)
    if status.success?
      if driver == "runonce"
        Rails.logger.info "JOB STATUS = DONE"
        job.update(status: :DONE, ended_at: Time.now)
        update(cases: [])
      else
        # upload
        _upload
      end
    else
      Rails.logger.info "JOB STATUS = FAILED"
      job.update(status: :FAILED, ended_at: Time.now)
    end
  end

  def _upload
    sqlite_filename = job.sqlite_filename
    Rails.logger.info "About to load #{sqlite_filename}"
    importer = WhatsOpt::SqliteCaseImporter.new(sqlite_filename)
    p importer.success
    operation_params = { cases: importer.cases_attributes, success: importer.success }
    update_operation(operation_params)
    save!
    # self.set_upload_job_done
    # Rails.logger.info "Cleanup #{sqlite_filename}"
    Rails.logger.info "Cleanup DISABLED"
    # File.delete(sqlite_filename)
  end

  def _set_upload_job_done
    if job
      job.update(status: "DONE", pid: -1, log: job.log << "Data uploaded\n", log_count: job.log_count + 1, ended_at: Time.now)
    else # wop upload
      create_job(status: "DONE", pid: -1, log: "Data uploaded\n", log_count: 1, started_at: Time.now, ended_at: Time.now)
    end
  end

  def _build_cases(case_attrs)
    var = {}
    case_attrs.each do |c|
      vname = c[:varname]
      var[vname] ||= Variable.where(name: vname, io_mode: WhatsOpt::Variable::OUT)
                             .joins(discipline: :analysis)
                             .where(analyses: { id: analysis.id })
                             .take
      cases.build(variable_id: var[vname].id, coord_index: c[:coord_index], values: c[:values])
    end
  end

  def _update_cases(case_attrs)
    cases.map(&:destroy)
    cases.reload
    _build_cases(case_attrs)
  end
end
