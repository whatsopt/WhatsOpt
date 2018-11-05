require 'zip'
require 'csv'

module WhatsOpt  
  class CsvCaseGenerator

    def initialize(zip: false)
      @zip = !!zip
    end
            
    def generate(cases)
      basename = "cases"

      return "", "#{basename}.zip" if cases.empty?
            
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
    
      content = CSV.generate(col_sep: ';') do |csv|
        csv << headers
        values.each do |v|
          csv << v
        end
      end
            
      if @zip
        stringio = Zip::OutputStream::write_buffer do |zio|
          zio.put_next_entry("#{basename}.csv") 
          zio.write content
        end
        stringio.rewind
        return stringio.read, "#{basename}.zip"
      else
        return content, "#{basename}.csv"
      end
    end
    
  end
end
