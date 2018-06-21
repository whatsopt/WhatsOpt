require 'whats_opt/openmdao_generator'

class Operation < ApplicationRecord
	
  belongs_to :analysis
	has_many :cases, :dependent => :destroy
	
  scope :in_progress, ->(analysis) { Operation.where(analysis: analysis).left_outer_joins(:cases).where(cases: {operation_id: nil}) }
  scope :done, ->(analysis) { Operation.where(analysis: analysis).left_outer_joins(:cases).where.not(cases: {operation_id: nil}).uniq }
	
	def self.build_operation(mda, ope_attrs)
	  operation = mda.operations.build(ope_attrs.except(:cases))
	  operation._build_cases_from(ope_attrs[:cases])
	  operation
	end

	def update_operation(ope_attrs)
    name = ope_attrs[:name]
    driver = ope_attrs[:driver]
    _build_cases_from(ope_attrs[:cases])
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
       cases.build(variable_id: var[name].id, coord_index: coord_index, values: c[:values])
     end     
   end
	
end