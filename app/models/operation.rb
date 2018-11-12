require 'whats_opt/openmdao_generator'

class Operation < ApplicationRecord
	
  CAT_RUNONCE = :analysis
  CAT_OPTIMISATION = :optimization 
  CAT_SCREENING = :screening
  CAT_DOE = :doe 
  CATEGORIES = [CAT_RUNONCE, CAT_OPTIMISATION, CAT_DOE, CAT_SCREENING]
  
  TERMINATION_STATUSES = %w(DONE, FAILED, KILLED)
  STATUSES = %w(PENDING, RUNNING)+TERMINATION_STATUSES
    
  belongs_to :analysis
  has_many :options, :dependent => :destroy
  accepts_nested_attributes_for :options, reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true  
  
	has_many :cases, :dependent => :destroy
	has_one :job, :dependent => :destroy
	
  validates :name, presence: true, allow_blank: false

  scope :in_progress, ->(analysis) { Operation.where(analysis: analysis).left_outer_joins(:cases).where(cases: {operation_id: nil}) }
  scope :done, ->(analysis) { Operation.where(analysis: analysis).left_outer_joins(:cases).where.not(cases: {operation_id: nil}).uniq }
	
	def self.build_operation(mda, ope_attrs)
	  operation = mda.operations.build(ope_attrs.except(:cases))
	  operation._build_cases(ope_attrs[:cases]) if ope_attrs[:cases]
    if ope_attrs[:cases]
      operation.build_job(status: 'DONE', pid: -1, log: "")
    else
      operation.build_job(status: 'PENDING', pid: -1, log: "")
    end
	  operation
	end

	def update_operation(ope_attrs)
	  if (ope_attrs[:options_attributes])
      ope_attrs[:options_attributes].each do |opt|
        opt[:value] = opt[:value].to_s
      end
	  end
	  self.update(ope_attrs.except(:cases))
    if ope_attrs[:cases]
      self._update_cases(ope_attrs[:cases])
      self._set_upload_job_done
    end
  end

  def update_on_termination(status)
    if status.success?
      if ope.driver == "runonce"
        Rails.logger.info "JOB STATUS = DONE"          
        ope.job.update(status: :DONE, ended_at: Time.now)
        ope.update(cases: [])
      else
        # upload
        _upload(ope)
      end 
    else
      Rails.logger.info "JOB STATUS = FAILED"
      job.update(status: :FAILED, ended_at: Time.now)
    end
  end
  
  def _upload(ope)
    Rails.logger.info "About to load #{sqlite_filename}"
    sqlite_filename = ope.job.sqlite_filename
    importer = WhatsOpt::SqliteCaseImporter.new(sqlite_filename)
    operation_params = {cases: importer.cases_attributes}
    ope.update_operation(operation_params)
    ope.save!
    #ope.set_upload_job_done
    #Rails.logger.info "Cleanup #{sqlite_filename}"
    Rails.logger.info "Cleanup DISABLED"
    #File.delete(sqlite_filename)
  end
    
  def _set_upload_job_done
    if self.job
      self.job.update(status: 'DONE', pid: -1, log: self.job.log + "Data uploaded\n", ended_at: Time.now)
    else # wop upload
      self.create_job(status: 'DONE', pid: -1, log: "Data uploaded\n", started_at: Time.now, ended_at: Time.now)
    end
  end
  
	def to_plotter_json
    adapter = ActiveModelSerializers::SerializableResource.new(self)
    adapter.to_json
	end
	
	def category
    case driver
    when "runonce"
      'analysis'
    when /optimizer/
      'optimization'
    when /morris/
      'screening'
    else
      'doe'
	  end 
	end
	
	def nb_of_points
	  if cases.empty?
	    0
	  else
	    cases[0].nb_of_points
	  end
	end
	
	def option_hash
    options.map{|h| [h['name'].to_sym, h['value']]}.to_h
	end
	
  def _build_cases(case_attrs)
    var = {}
    case_attrs.each do |c|
      vname = c[:varname]
      var[vname] ||= Variable.where(name: vname)
                            .joins(discipline: :analysis)
                            .where(analyses: {id: self.analysis.id})
                            .take
      self.cases.build(variable_id: var[vname].id, coord_index: c[:coord_index], values: c[:values])
    end     
  end
	
  def _update_cases(case_attrs)
    self.cases.map(&:destroy)
    _build_cases(case_attrs)
  end
  
end