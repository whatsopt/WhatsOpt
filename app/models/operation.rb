class Operation < ApplicationRecord
	
  belongs_to :analysis
	has_many :cases, :dependent => :destroy
	
	def create_cases!(cases)
	  _create_cases_from!(cases)
	end
	
	def to_plotter_json
    adapter = ActiveModelSerializers::SerializableResource.new(self)
    adapter.to_json
	end
	
	private
	
	  def _create_cases_from!(vars, varscope=Variable)
	    vars.each do |name, values|
	      name_split = name.split(" ")
	      n = name_split[0]
        coord_index = 0
        if (name_split.size > 1)
          coord_index = name_split[1] 
	      end
        var = varscope.where(name: n)
                .joins(discipline: :analysis)
                  .where(analyses: {id: self.analysis.id})
                .take
        cases.create!(variable_id: var.id, coord_index: coord_index, values: values)
      end	    
	  end
	
end