module WhatsOpt

  class ExcelMdaImporter2
    
    CONTROL_NAME = '__CONTROL__'
    GSV_SHEET_NAME = 'Global State Vector'
    DISCIPLINE_RANGE_NAME = 'discipline_list'
    GLOBAL_STATE_VECTOR = 'global_state_vector'
    
    class ImportError < StandardError
    end
    
    attr_reader :line_count, :mda, :disciplines, :variables, :connections, :defined_names
    
    FIRST_LINE_NB = 15
    
    
    def initialize(filename)
      @filename = filename
      begin
        @workbook = RubyXL::Parser.parse(filename)
      rescue Zip::Error => e
        # puts e.message
        raise ImportError.new
      end 
      _initialize_defined_names
      @worksheet = @workbook[GSV_SHEET_NAME]
      top_right, bottom_left = _get_coordinates(DISCIPLINE_RANGE_NAME)
      @disc_table = @worksheet[top_right[0]...bottom_left[0]]
      @disc_data = @disc_table.map{|row| row && row[top_right[1]..bottom_left[1]]}
        
      top_right, bottom_left = [[14, 1], [23, 15]]
      @main_table = @worksheet[top_right[0]...bottom_left[0]]
      @workdata = @main_table.map{|row| row && row[top_right[1]..bottom_left[1]]} 
      @workdata.compact!
    end
            
    def import_all 
      _import_disciplines_data
      _import_variables_data
      _import_connections_data
    end
        
    def _initialize_defined_names
      @defined_names = {}
      for elt in @workbook.defined_names
        @defined_names[elt.name] = elt.reference
      end
    end
    
    def _get_coordinates(range_name)
      @defined_names[range_name] =~ /(.*)!\$(.*)\$(.*):\$(.*)\$(.*)/
      top_left_ref = RubyXL::Reference.ref2ind("#{$2}#{$3}")
      bottom_right_ref = RubyXL::Reference.ref2ind("#{$4}#{$5}")
      return top_left_ref, bottom_right_ref
    end
      
    def get_mda_attributes
      { name: @worksheet[1][1].value }
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
        # TODO: use the discipline code, for now suppose they are
        # ordered in the increasing code number: 0,1,2,...
        @disciplines = @disc_data.map{|row| _getstr(row[0])}
        @disciplines.map!(&:camelize)
      end   
      @disciplines
    end
    
    def _import_variables_data
      unless @variables
        @variables = {}
        @workdata.each do |row|
          name = _getstr(row[3])
          shape = case _getstr(row[5])
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
          type = (_getstr(row[7]) =~ /int/) ? Variable::INTEGER_T : Variable::FLOAT_T
          units = _getstr(row[6])
          units = case units
                  when /degre/, /degré/ # format compatibility cicav excel
                    "deg"
                  when '(-)'
                    ""   
                  else
                    units
                  end
          desc = _getstr(row[4])
          disabled = (_getstr(row[0]) == 'false')  
          @variables[name] = {name: name, shape: shape, type: type, 
                              units: units, desc: desc, disabled: disabled}
        end
      end
      return @variables
    end
    
    def _import_connections_data()
      @connections = {}
      flows = @workdata.map{|row| row && row[8..13]}
      vars = @workdata.map{|row| row && row[3]}
      flows.each_with_index do |row, i|
        var = _getstr(vars[i]) 
        row.each do |c|
          if c && c.value
            val = _getstr(c)
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
    
    def _getstr(row_element)
      s = row_element && row_element.value.to_s.strip
      s
    end
            
  end # class

end # module
