require 'zip'
require 'csv'

module WhatsOpt  
  class CsvCaseGenerator < CsvGenerator
            
    def _generate(cases)
      @basename = "cases"

      headers = cases.map do |c| 
        varname = c.variable&.name || "unknown_#{c.variable_id}"
        if c.coord_index > -1 
          "#{varname}[#{c.coord_index}]"
        else
          varname
        end
      end
      
      vals = cases.map {|c| c.values}
      cases0 = vals.shift 
      values = cases0.zip(*vals)
    
      return headers, values
    end
    
  end
end
