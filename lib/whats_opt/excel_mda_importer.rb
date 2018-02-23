require 'whats_opt/mda_importer'
require 'whats_opt/utils' 

module WhatsOpt

  class ExcelMdaImporter < MdaImporter
    
    include WhatsOpt::Utils
    
    GSV_SHEET_NAME = 'Global State Vector'
    GLOBAL_STATE_VECTOR = 'global_state_vector'
    DISCIPLINE_SHEET_NAME = 'Disciplines'
    DISCIPLINE_RANGE_NAME = 'discipline_list'
    
    class ExcelMdaImportError < MdaImportError
    end
    
    attr_reader :line_count, :mda, :disciplines, :variables, :connections, :defined_names
    
    def initialize(filename, mda_name=nil)
      @filename = filename
      @mda_name = mda_name || File.basename(@filename, '.*').camelcase
      begin
        @workbook = RubyXL::Parser.parse(filename)
      rescue Zip::Error => e
        # puts e.message
        raise ExcelMdaImportError.new(e)
      end 
      _initialize_defined_names
      @worksheet = @workbook[DISCIPLINE_SHEET_NAME]
      top_right, bottom_left = _get_coordinates(DISCIPLINE_RANGE_NAME)
      @disc_table = @worksheet[top_right[0]...bottom_left[0]]
      @disc_data = @disc_table.map{|row| row && row[top_right[1]..bottom_left[1]]}
        
      @worksheet = @workbook[GSV_SHEET_NAME]
      top_right, bottom_left = _get_coordinates(GLOBAL_STATE_VECTOR)
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
      { name: @mda_name }
    end 
    
    def get_disciplines_attributes
      _import_disciplines_data
      @disciplines.map { |d| {id: d, name: d} }
    end
    
    def get_variables_attributes
      import_all
      res = {}
      (self.disciplines).each do |d|
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
            v = varattr.merge(io_mode: 'out')
            res[src].append(v) unless res[src].include?(v) 
            dsts.each do |dst|
              v = varattr.merge(io_mode: 'in')
              v.merge!(parameter_attributes: {init: @init_values[v[:name]]}) if @init_values[v[:name]]
              res[dst].append(v) unless res[dst].include?(v)
            end  
          elsif k =~ /[CY](\d)(\d)/
            src = _to_discipline($1) 
            dst = _to_discipline($2)
            v = varattr.merge(io_mode: 'out')
            res[src].append(v) unless res[src].include?(v) 
            v = varattr.merge(io_mode: 'in')
            v.merge!(parameter_attributes: {init: @init_values[v[:name]]}) if @init_values[v[:name]]
            res[dst].append(v) unless res[dst].include?(v) 
          elsif k =~ /Y(\d)/
            src = _to_discipline($1)
            dst = WhatsOpt::Discipline::NULL_DRIVER_NAME
            v = varattr.merge(io_mode: 'out')
            res[src].append(v) unless res[src].include?(v) 
            v = varattr.merge(io_mode: 'in')
            v.merge!(parameter_attributes: {init: @init_values[v[:name]]}) if @init_values[v[:name]]
            res[dst].append(v) unless res[dst].include?(v) 
          elsif k =~ /X(\d)/
            src = WhatsOpt::Discipline::NULL_DRIVER_NAME
            dst = _to_discipline($1)
            v = varattr.merge(io_mode: 'out')
            res[src].append(v) unless res[src].include?(v) 
            v = varattr.merge(io_mode: 'in')
            v.merge!(parameter_attributes: {init: @init_values[v[:name]]}) if @init_values[v[:name]]
            res[dst].append(v) unless res[dst].include?(v) 
          else     
            raise ExcelMdaImportError.new("Bad flow '#{k}' for variable #{varname}")
          end
        end 
      end
      res
    end
    
    def _to_discipline(idx)
      _import_disciplines_data
      if idx =~ /\d/ && idx.to_i+1 < self.disciplines.length
        d = self.disciplines[idx.to_i+1] 
      else
        d = WhatsOpt::Discipline::NULL_DRIVER_NAME
      end
      d
    end
    
    def _to_other_disciplines(idx)
      _import_disciplines_data
      d = []
      if idx =~ /\d/ && idx.to_i+1 < self.disciplines.length
        d = self.disciplines - [self.disciplines[idx.to_i+1]] - [WhatsOpt::Discipline::NULL_DRIVER_NAME]
      end
      d
    end

    def _import_disciplines_data
      unless @disciplines
        # TODO: use the discipline code, for now suppose they are
        # ordered in the increasing code number: 0,1,2,...
        @disciplines = @disc_data.map{|row| _getstr(row[0])}
        @disciplines.map!(&:camelize)
        @disciplines = [WhatsOpt::Discipline::NULL_DRIVER_NAME] + @disciplines
      end   
      @disciplines
    end
    
    def _import_variables_data
      unless @variables
        @variables = {}
        @init_values = {}
        @workdata.each do |row|
          name = _getstr(row[3])
          next if name.blank?  # named range start on 'insert below line' => generate "" varname
          initval_or_shape = _getstr(row[5])
          shape = "1"
          initval = nil
          case initval_or_shape
          when /\(\s*(\d+)\s*,\s*\)/
            shape = "(#{$1},)"
          when /\(\s*(\d+)\s*,\s*(\d+)\s*\)/  
            shape = "(#{1}, #{2})"
          when /\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)/
            shape = "(#{$1}, #{$2}, #{$3})"
          else # 
            unless initval_or_shape.nil?
              initval = initval_or_shape
              shape = self.shape_of initval
            end
          end
          type = _getstr(row[7])
          type = case type
                 when /int/, /Integer/
                   Variable::INTEGER_T
                 when /string/, /String/  
                   Variable::STRING_T
                 else # 
                   Variable::FLOAT_T
                 end          
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
          unless initval.blank?
            @init_values[name] = initval  # used as is
          end
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
        next if row.nil?
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
