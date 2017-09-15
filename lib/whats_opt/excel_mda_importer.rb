module WhatsOpt

  class ExcelMdaImporter
    
    CONTROL_NAME = '__CONTROL__'
    
    class ImportError < StandardError
    end
    
    attr_reader :line_count, :mda, :disciplines, :variables, :connections
    
    FIRST_LINE_NB = 15
    
    def initialize(filename)
      @filename = filename
      begin
        @workbook = RubyXL::Parser.parse(filename)
      rescue Zip::Error => e
        # puts e.message
        raise ImportError.new
      end
      @worksheet = @workbook[0]
      workprobe = @worksheet[FIRST_LINE_NB..1024]
      @line_count = 0
      while workprobe[@line_count][5] && getstr(workprobe[@line_count][5]) =~ /\w+/
        @line_count += 1
      end 
      @worksheet = @worksheet[FIRST_LINE_NB...(FIRST_LINE_NB+@line_count)]
      @workdata = @worksheet.map{|row| row && row[4..18]}  # col E to col S
      @workdata.compact!
    end
            
    def import_all 
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
      import_all
      res = {}
      ([CONTROL_NAME]+self.disciplines).each do |d|
        res[d] = [] 
      end
      @connections.keys.each do |k|
        connections[k].each do |varname|
          varattr = self.variables[varname]
          next if varattr[:disabled]
          varattr.except!(:disabled)  # not an attribute of variable in database
          if k =~ /Y(\d)x/
            src = _to_discipline($1) 
            dsts = _to_other_disciplines($1)
            v = varattr.merge({io_mode: 'out'})
            res[src].append(v) unless res[src].include?(v) 
            dsts.each do |dst|
              v = varattr.merge({io_mode: 'in'})
              res[dst].append(v) unless res[dst].include?(v)
            end  
          elsif k =~ /[CY](\d)(\d)/
            src = _to_discipline($1) 
            dst = _to_discipline($2)
            v = varattr.merge({io_mode: 'out'})
            res[src].append(v) unless res[src].include?(v) 
            v = varattr.merge({io_mode: 'in'})
            res[dst].append(v) unless res[dst].include?(v) 
          elsif k =~ /Y(\d)/
            src = _to_discipline($1)
            dst = CONTROL_NAME
            v = varattr.merge({io_mode: 'out'})
            res[src].append(v) unless res[src].include?(v) 
            v = varattr.merge({io_mode: 'in'})
            res[dst].append(v) unless res[dst].include?(v) 
          elsif k =~ /X(\d)/
            src = CONTROL_NAME
            dst = _to_discipline($1)
            v = varattr.merge({io_mode: 'out'})
            res[src].append(v) unless res[src].include?(v) 
            v = varattr.merge({io_mode: 'in'})
            res[dst].append(v) unless res[dst].include?(v) 
          else     
            Rails.logger.error "Unknown connection pattern '#{k}' while importing #{@filename}"
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
        d = CONTROL_NAME
      end
      d
    end
    
    def _to_other_disciplines(idx)
      _import_disciplines_data
      d = []
      if idx =~ /\d/ && idx.to_i < self.disciplines.length
        d = self.disciplines - [self.disciplines[idx.to_i]]
      end
      d = [CONTROL_NAME] if d.empty?
      d
    end

    def _import_disciplines_data
      unless @disciplines
        @disciplines = @workdata.map{|row| getstr(row[1])}
        @disciplines = @disciplines.uniq.compact
        @disciplines.map!(&:camelize)
      end   
      @disciplines
    end
    
    def _import_variables_data
      unless @variables
        @variables = {}
        @workdata.each do |row|
          name = getstr(row[12])
          shape = case getstr(row[3])
                  when /scalar/, /scalaire/ # format backward compatibility 
                    '1'
                  when /table/  # format compatibility cicav excel
                    '(10,)'
                  when /^(\d+)$/, /^\((\d+),\)$/
                    if $1.to_i > 1 
                      "(#{$1},)"
                    else
                      "#{1}"  
                    end
                  when /^\((\d+),\s*(\d+)\)$/  
                    "(#{1}, #{2})"
                  when /\((\d+),\s*(\d+),\s*(\d+)\)/
                    "(#{1}, #{2}, #{3})"
                  else
                    '0'
                  end
          type = (getstr(row[4]) =~ /int/) ? Variable::INTEGER_T : Variable::FLOAT_T
          units = getstr(row[5])
          units = case units
                  when /degre/, /degré/ # format compatibility cicav excel
                    "deg"
                  when '(-)'
                    ""   
                  else
                    units
                  end
          desc = getstr(row[0])
          disabled = !!(getstr(row[14]) =~ /^y$|^yes$|^o$|^oui$/)  
          @variables[name] = {name: name, shape: shape, type: type, 
                              units: units, desc: desc, disabled: disabled}
        end
      end
      return @variables
    end
    
    def _import_connections_data()
      @connections = {}
      flows = @workdata.map{|row| row && row[6..11]}
      vars = @workdata.map{|row| row && row[12]}
      flows.each_with_index do |row, i|
        var = getstr(vars[i]) 
        row.each do |c|
          if c && c.value
            val = getstr(c)
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
    
    def getstr(row_element)
      row_element && row_element.value.to_s.strip
    end
            
  end # class

end # module
