module WhatsOpt

  class ExcelMdaImporter
    
    USER_DISCIPLINE = '__User__'
    
    class ImportError < StandardError
    end
    
    attr_reader :line_count, :mda, :disciplines, :variables, :connections
    
    FIRST_LINE_NB = 15
    
    def initialize(filename)
      begin
        @workbook = RubyXL::Parser.parse(filename)
      rescue Zip::Error => e
        # puts e.message
        raise ImportError.new
      end
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
            
    def import 
      _import_disciplines_data
      _import_variables_data
      _import_connections_data
    end
    
    def get_mda_attributes
      { name: @workbook[0][1][1].value }
    end 
    
    def get_disciplines_attributes
      _import_disciplines_data
      @disciplines.map { |d| {name: d} }
    end
    
    def get_variables_attributes
      self.import
      res = {}
      ([USER_DISCIPLINE]+self.disciplines).each do |d|
        res[d] = [] 
      end
      @connections.keys.each do |k|
        connections[k].each do |varname|
          varattr = self.variables[varname]
          if k =~ /Y(\w)(\w)/
            src = _to_discipline($1) 
            dst = _to_discipline($2)
            res[src].append(varattr.merge({io_mode: 'out'}))
            res[dst].append(varattr.merge({io_mode: 'in'}))
          elsif k =~ /X(\w)/
            dst = _to_discipline($1)
            res[dst].append(varattr.merge({io_mode: 'in'}))
          else     
            puts "Unknown connection: #{k}"
          end
        end 
      end
      res
    end
        
    def _to_discipline(idx)
      _import_disciplines_data
      if idx =~ /\d/ && idx.to_i < self.disciplines.length
        d = self.disciplines[idx.to_i] 
      else
        d = USER_DISCIPLINE
      end
      return d
    end
    
    def _import_disciplines_data
      unless @disciplines
        @disciplines = @workdata.map{|row| row && row[1].value}
        @disciplines = @disciplines.uniq.compact
        @disciplines.map!(&:camelize)
      end   
      return @disciplines
    end
    
    def _import_variables_data
      unless @variables
        @variables = {}
        @workdata.each do |row|
          @variables[row[12].value] = {name: row[12].value, kind: row[3].value, unit: row[5].value}
        end
      end
      return @variables
    end
    
    def _import_connections_data()
      @connections = {}
      flows = @workdata.map{|row| row && row[6..11]}
      vars = @workdata.map{|row| row && row[12]}
      flows.each_with_index do |row, i|
        var = vars[i] && vars[i].value
        row.each do |c|
          val = c && c.value
          if val 
            if @connections.has_key? val
              @connections[val].append(var)
            else
              @connections[val] = [var]
            end  
          end
        end
      end
      return @connections
    end
            
  end # class

end # module
