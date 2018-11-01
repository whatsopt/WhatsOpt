require 'zip'
require 'csv'

module WhatsOpt  
  class CsvCaseGenerator
        
    def generate(cases)
      basename = "cases"

      return "", "#{basename}.zip" if cases.empty?
            
      headers = cases.map do |c| 
        if c.coord_index > -1 
          "#{c.variable.name}[#{c.coord_index}]"
        else
          c.variable.name
        end
      end
      
      vals = cases.map {|c| c.values}
      cases0 = vals.shift 
      values = cases0.zip(*vals)
    
      content = CSV.generate do |csv|
        csv << headers
        values.each do |v|
          csv << v
        end
      end
      
      stringio = Zip::OutputStream::write_buffer do |zio|
        zio.put_next_entry("#{basename}.csv") 
        zio.write content
      end
      stringio.rewind
      return stringio.read, "#{basename}.zip"

    end
    
  end
end
