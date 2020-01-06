# frozen_string_literal: false

require "socket"
require "whats_opt/openmdao_generator"
require "whats_opt/sqlite_case_importer"


class Operation < ApplicationRecord
  CAT_RUNONCE = "analysis"
  CAT_OPTIMISATION = "optimization"
  CAT_DOE = "doe"
  CAT_SENSITIVITY_DOE = "sensitivity_doe"
  CAT_SENSITIVITY = "sensitivity_analysis"
  CAT_METAMODEL = "metamodel"
  CATEGORIES = [CAT_RUNONCE, CAT_OPTIMISATION, 
                CAT_DOE, CAT_SENSITIVITY_DOE,
                CAT_SENSITIVITY, CAT_METAMODEL].freeze

  BATCH_COUNT = 10 # nb of log lines processed together
  LOGDIR = File.join(Rails.root, "upload/logs")

  class ForbiddenRemovalException < Exception; end

  belongs_to :analysis
  has_many :options, dependent: :destroy
  accepts_nested_attributes_for :options, reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true

  has_one :job, dependent: :destroy

  # when optimization / doe
  has_many :cases, -> { joins(:variable).order("name ASC") }, dependent: :destroy
  # when meta model building operation
  has_one :meta_model
  # when derived from doe
  has_many :derived_operations, class_name: 'Operation', foreign_key: 'base_operation_id', inverse_of: :base_operation
  belongs_to :base_operation, class_name: 'Operation', foreign_key: 'base_operation_id', inverse_of: :derived_operations 

  before_destroy :_check_allowed_destruction

  validates :name, presence: true, allow_blank: false
  validates :driver, presence: true, allow_blank: false
  validate :success_flags_consistent_with_cases

  scope :in_progress, ->(analysis) { where(analysis: analysis).joins(:job).where(jobs: {status: Job::WIP_STATUSES}) } 
  scope :successful, ->() { joins(:job).where(jobs: {status: Job::SUCCESS_STATUSES}) }
  scope :final, ->() { where.not(id: pluck(:base_operation_id).compact) }
  scope :done, ->(analysis) { where(analysis: analysis).successful }

  serialize :success, Array

  def success_flags_consistent_with_cases
    if (cases.blank? && !success.blank?) || (!cases.blank? && (cases[0].values.size != success.size))
      errors.add(:success, "size (#{success.size}) can not be different from cases values size (#{cases.blank? ? 0 : cases[0].values.size})")
    end
  end

  def self.build_operation(mda, ope_attrs)
    operation = mda.operations.build(ope_attrs.except(:cases))
    operation.name = ope_attrs[:driver] unless ope_attrs[:name]
    operation._build_cases(ope_attrs[:cases]) if ope_attrs[:cases]
    opecat = operation.category
    case opecat
    when CAT_DOE, CAT_SENSITIVITY_DOE, CAT_OPTIMISATION
      operation.build_job(status: :DONE_OFFLINE)
      operation.build_derived_operations
    when CAT_METAMODEL
      operation.build_job(status: :ASSUME_DONE)
      operation.build_derived_operations
    else
      operation.build_job(status: :PENDING)
    end
    operation
  end

  def build_derived_operations
    case self.category
    when CAT_SENSITIVITY_DOE
      if self.driver =~ /(\w+)_doe_(\w+)/
        library = $1
        algo = $2
        derived = self.derived_operations.build(name: "Sensitivity #{algo}", 
                                                driver: "#{library}_sensitivity_#{algo}",
                                                analysis_id: self.analysis_id)
        derived.build_job(status: "ASSUME_DONE")
      else
        Rails.logger.warn('Unknown sensitivity method for sensitivity DOE driver #{self.driver}')
      end
    when CAT_METAMODEL
      if self.driver =~ /(openturns)_metamodel_(pce)/
        library = $1
        algo = $2
        derived = self.derived_operations.build(name: "Sensitivity #{algo}", 
                                                driver: "#{library}_sensitivity_#{algo}",
                                                analysis_id: self.analysis_id)
        derived.build_job(status: "ASSUME_DONE")
      end
    end
  end

  def build_metamodel_varattrs(varnames = nil)
    input_vars = analysis.design_variables
    input_vars = input_vars.select { |v| varnames[:inputs].include?(v.name) } if varnames && varnames[:inputs]
    output_vars = analysis.response_variables
    output_vars = output_vars.select { |v| varnames[:outputs].include?(v.name) } if varnames && varnames[:outputs]
    varattrs = {}
    cases.each do |c|
      varattr = ActiveModelSerializers::SerializableResource.new(c.variable).as_json
      if varattrs.keys.include?(c.variable.name)
        if varattr[:io_mode] == WhatsOpt::Variable::IN
          varattr[:parameter_attributes][:lower] = [c.values.min, varattr[:parameter_attributes][:lower].to_f].min.to_s
          varattr[:parameter_attributes][:upper] = [c.values.max, varattr[:parameter_attributes][:lower].to_f].max.to_s
        end
      else
        if input_vars.include?(c.variable)
          varattr[:io_mode] = WhatsOpt::Variable::IN
          varattr[:parameter_attributes] = {} unless varattr[:parameter_attributes]
          varattr[:parameter_attributes][:lower] = c.values.min.to_s if varattr[:parameter_attributes][:lower].blank?
          varattr[:parameter_attributes][:upper] = c.values.max.to_s if varattr[:parameter_attributes][:upper].blank?
        elsif output_vars.include?(c.variable)
          varattr[:io_mode] = WhatsOpt::Variable::OUT
          varattr[:parameter_attributes] = {} unless varattr[:parameter_attributes]
        else
          next
        end
        varattrs[varattr[:name]] = varattr
      end
    end
    varattrs.values
  end

  def to_plotter_json
    adapter = ActiveModelSerializers::SerializableResource.new(self)
    adapter.to_json
  end

  def rerunnable?
    # if started_at is nil, the operation was not run from WhatsOpt server 
    # hence non runnable again.
    self.job && self.job.started_at 
  end

  def success?
    self.job && self.job.success? 
  end

  def sensitivity_analysis?
    self.category == CAT_SENSITIVITY
  end

  def meta_model?
    self.category == CAT_METAMODEL
  end

  def category
    @category ||=
      case driver
      when "runonce"
        CAT_RUNONCE
      when /optimizer/, /slsqp/, /scipy/, /pyoptsparse/
        CAT_OPTIMISATION
      when /_metamodel_/
        CAT_METAMODEL
      when /_doe_morris/, /doe_sobol/
        CAT_SENSITIVITY_DOE
      when /_sensitivity_morris/, /_sensitivity_sobol/, /_sensitivity_pce/
        CAT_SENSITIVITY
      when /doe/, /lhs/
        CAT_DOE
      else
        if !analysis.objective_variables.empty?
          CAT_OPTIMISATION
        else
          CAT_DOE
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

  def ope_cases
    base_operation ? base_operation.ope_cases : cases.sort_by{|c| c.label}
  end

  def input_cases
    ope_cases.select { |c| c.variable.is_connected_as_input_of_interest? }
  end

  def output_cases
    ope_cases.select { |c| c.variable.is_connected_as_output_of_interest? }
  end

  def sorted_cases
    input_cases + output_cases
  end

  def build_copy(analysis, varnames=[]) 
    ope_copy = analysis.operations.build(self.attributes.except("id"))
    ope_copy.job = self.job.build_copy
    self.cases.each do |c|
      vname = c.variable.name
      if varnames.empty? || varnames.include?(vname)

        dest_variable = Variable.of_analysis(analysis)
                          .where(name: vname, io_mode: WhatsOpt::Variable::OUT)
                          .take
        c_copy =  c.build_copy(ope_copy, dest_variable)
        ope_copy.cases << c_copy
      end
    end
    if base_operation
      ope_copy.base_operation = base_operation.build_copy(analysis, varnames)
    end
    ope_copy
  end

  def perform
    ogen = WhatsOpt::OpenmdaoGenerator.new(analysis, server_host: host, driver_name: driver, driver_options: option_hash)
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
      job.update(pid: -1, log: job.log << "Data uploaded\n", log_count: job.log_count + 1, ended_at: Time.now)
      if job.started?
        job.update(status: :DONE) 
      else
        job.update(status: :DONE_OFFLINE) 
      end
    else # wop upload first time
      create_job(status: :DONE_OFFLINE, pid: -1, log: "Data uploaded\n", log_count: 1, started_at: Time.now, ended_at: Time.now)
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

  def _check_allowed_destruction
    # unless self.meta_models.empty?
    #   mdas = self.meta_models.map(&:analysis)
    #   msg = mdas.map {|a| "##{a.id} #{a.name}"}.join(', ')
    #   raise ForbiddenRemovalException.new("Can not delete operation '#{self.name}' as meta_models are in use: #{msg} (to be deleted first)")
    # end
    unless self.derived_operations.empty?
      msg = self.derived_operations.map(&:name).join(', ')
      raise ForbiddenRemovalException.new("Can not delete operation '#{self.name}' as another operation depends on it: #{msg} (to be deleted first)")
    end
  end
end
