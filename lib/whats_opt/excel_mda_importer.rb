module WhatsOpt

  class ExcelMdaImporter
    
    def initialize(filename)
      @workbook = RubyXL::Parser.parse(filename)
      @worksheet = @workbook[0]
      @workdata = @worksheet[15..248].map{|row| row && row[4..16]} 
      @workdata.compact!
    end

    def get_disciplines
      disciplines = @workdata.map{|row| row && row[1].value}
      disciplines.uniq!.compact!
      return disciplines
    end
    
    def get_variables(discipline)
      #variables = @workdata.select{|row| row && row[1].value == discipline}
      #variables = .map{|row| row && row[12].value}
      #variables.uniq!.compact!
      #return variables
    end

  end

end
