class Operation < ApplicationRecord
	
  belongs_to :analysis
	has_many :cases, :dependent => :destroy
	
	def create_cases!(data)
	  p data
	  _create_cases_from!(data[:inputs], Variable.inputs)
    _create_cases_from!(data[:outputs], Variable.outputs)
	end
	
	private
	
	  def _create_cases_from!(vars, varscope)
	    vars.each do |name, values|
	      n = name.split(" ")[0]
        var = varscope.where(name: n)
                .joins(discipline: :analysis)
                  .where(analyses: {id: self.analysis.id})
                .take
        cases.create!(variable_id: var.id, values: values)
      end	    
	  end
	
end