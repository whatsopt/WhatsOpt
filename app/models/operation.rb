class Operation < ApplicationRecord
	
  belongs_to :analysis
	has_many :cases, :dependent => :destroy
	
	def self.build_operation(mda, ope_attrs)
	  operation = mda.operations.build(name: ope_attrs[:name])
	  operation._build_cases_from(ope_attrs[:cases])
	  operation
	end
	
	def to_plotter_json
    adapter = ActiveModelSerializers::SerializableResource.new(self)
    adapter.to_json
	end
	
  def _build_cases_from(vars, varscope=Variable)
     var = {}
     vars.each do |c|
       name = c[:varname]
       coord_index = c[:coord_index]
       var[name] ||= varscope.where(name: name)
                       .joins(discipline: :analysis)
                       .where(analyses: {id: self.analysis.id})
                       .take
       cases.build(variable_id: var[name].id, coord_index: coord_index, values: c[:values])
     end     
   end
	
end