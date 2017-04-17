module WhatsOpt

  class ExcelMdaImporter
    
    attr_reader :line_count
    
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
      disciplines = @workdata.map{|row| row && row[1].value}
      disciplines = disciplines.uniq.compact
      return disciplines
    end
    
    def get_variables(discipline)
      rows = @workdata.select{|row| row && row[1].value == discipline}
      rows.compact!
      variables = []
      rows.each do |row|
        variables.append({name: row[12].value, type: row[3].value, unit: row[5].value})
      end
      return variables
    end
    
    def get_connections()
      flows = @workdata.map{|row| row && row[6..12]}
      flows.each do |f|
        puts f[0].value
      end
      return {}
    end

  end

end
