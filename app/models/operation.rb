require 'whats_opt/openmdao_generator'

class Operation < ApplicationRecord
	
  TERMINATION_STATUSES = %w(DONE, FAILED, KILLED)
  STATUSES = %w(PENDING, RUNNING)+TERMINATION_STATUSES
    
  belongs_to :analysis
	has_many :cases, :dependent => :destroy
	has_one :job, :dependent => :destroy
	
  scope :in_progress, ->(analysis) { Operation.where(analysis: analysis).left_outer_joins(:cases).where(cases: {operation_id: nil}) }
  scope :done, ->(analysis) { Operation.where(analysis: analysis).left_outer_joins(:cases).where.not(cases: {operation_id: nil}).uniq }
	
	def self.build_operation(mda, ope_attrs)
	  operation = mda.operations.build(ope_attrs.except(:cases))
	  operation._build_cases_from(ope_attrs[:cases]) if ope_attrs[:cases]
	  operation.build_job(status: 'PENDING', pid: -1, log: "")
	  operation
	end

	def update_operation(ope_attrs)
    self.name = ope_attrs[:name] if ope_attrs[:name]
    self.host = ope_attrs[:host] if ope_attrs[:host]
    self.driver = ope_attrs[:driver] if ope_attrs[:driver]
    self._build_cases_from(ope_attrs[:cases]) if ope_attrs[:cases]
  end

	def to_plotter_json
    adapter = ActiveModelSerializers::SerializableResource.new(self)
    adapter.to_json
	end
	
	def category
    case driver
    when "runonce"
      'analysis'
    when "slsqp"
      'optimization'
    when "morris"
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
	
  def _build_cases_from(case_attrs)
     var = {}
     case_attrs.each do |c|
       name = c[:varname]
       coord_index = c[:coord_index]
       var[name] ||= Variable.where(name: name)
                       .joins(discipline: :analysis)
                       .where(analyses: {id: self.analysis.id})
                       .take
       self.cases.build(variable_id: var[name].id, coord_index: coord_index, values: c[:values])
     end     
   end
	
end