module WhatsOpt

  class ExcelMdaImporter
    
    attr_reader :line_count, :disciplines, :variables
    
    FIRST_LINE_NB = 15
    
    def initialize(filename)
      @workbook = RubyXL::Parser.parse(filename)
      @worksheet = @workbook[0]
      workprobe = @worksheet[FIRST_LINE_NB..1024]
      @line_count = 0
      while workprobe[@line_count][5]
        @line_count += 1
      end 
      @worksheet = @worksheet[FIRST_LINE_NB...(FIRST_LINE_NB+@line_count)]
      @workdata = @worksheet.map{|row| row && row[4..16]}
      @workdata.compact!
    end
    
    def get_disciplines
      unless @disciplines
        @disciplines = @workdata.map{|row| row && row[1].value}
        @disciplines = @disciplines.uniq.compact
        @disciplines.map!(&:camelize)
      end   
      return @disciplines
    end
    
    def get_variables(discipline)
      unless @variables
        rows = @workdata.select{|row| row && row[1].value.camelize == discipline}
        rows.compact!
        @variables = []
        rows.each do |row|
          @variables.append({name: row[12].value, type: row[3].value, unit: row[5].value})
        end
      end
      return variables
    end
    
    def get_connections()
      result = {}
      flows = @workdata.map{|row| row && row[6..11]}
      vars = @workdata.map{|row| row && row[12]}
      flows.each_with_index do |row, i|
        var = vars[i] && vars[i].value
        row.each do |c|
          val = c && c.value
          if val 
            if result.has_key? val
              result[val].append(var)
            else
              result[val] = [var]
            end  
          end
        end
      end
      return result
    end

  end # class

end
