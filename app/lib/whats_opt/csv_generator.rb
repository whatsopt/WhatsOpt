require 'zip'
require 'csv'

module WhatsOpt  
  class CsvGenerator

    def initialize(zip: false)
      @zip = !!zip
      @basename = "datafile"
      @content = ""
    end
           
    def generate(cases, success)
            
      headers, values = self._generate(cases, success)
      
      @content = CSV.generate(col_sep: ';') do |csv|
        csv << headers
        values.each do |v|
          csv << v
        end
      end
      
      if @zip
        stringio = Zip::OutputStream::write_buffer do |zio|
          zio.put_next_entry("#{@basename}.csv") 
          zio.write @content
        end
        stringio.rewind
        return stringio.read, "#{@basename}.zip"
      else
        return @content, "#{@basename}.csv"
      end
    end
    
    def _generate
      ""
    end
    
  end
end
