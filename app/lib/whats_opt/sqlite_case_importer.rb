require 'json'

module WhatsOpt  
  class SqliteCaseImporter
  
    attr_reader :driver_name, :num_cases, :cases, :cases_attributes, :success
    
    class BadSqliteFileError < StandardError
    end

    class BadDriverNameError < StandardError
    end

        
    def initialize(filename)
      @filename = filename
      unless is_valid_sqlite_db(filename)
        raise BadSqliteFileError.new
      end
      
      db = SQLite3::Database.new filename
      
      @success = []
      db.execute( "select iteration_coordinate, success from driver_iterations" ) do |row|
        if @driver_name.nil? && row[0] =~ /rank\d+:(\w+)/
          @driver_name = $1
        end
        @success << row[1]
      end
      
      @num_cases = 0
      @cases = {}
      db.execute( "select iteration_coordinate, inputs, outputs from system_iterations" ) do |row|
        if row[0] =~ /#{@driver_name}/
          cases = {}
          JSON.parse(row[1], {allow_nan: true}).each do |absname, values|
            cases[absname.split('.')[-1]] = values
          end
          JSON.parse(row[2], {allow_nan: true}).each do |absname, values|
            cases[absname.split('.')[-1]] = values
          end
          _insert_values(cases)
          @num_cases += 1
        end 
      end
      
      @cases_attributes = []
      cases.each do |key, values| 
        idx = key[1]
        idx = -1 if key[2] == 1 # consider it is a scalar not an array of 1 elt
        @cases_attributes.append({varname: key[0], coord_index: idx, values: values})
      end
    end
      
    def is_valid_sqlite_db(filename)
      unless File.exist?(filename)
        return false
      end
      if File.size(filename) < 100
        # SQLite database file header is 100 bytes
        return false
      end
      header = File.open(filename, 'rb').read(100)
      return header[0...16] == "SQLite format 3\x00".b
    end
    
    def _insert_values(cases)
      done = []
      cases.each do |name, v|
        next if done.include?(name)
        values = v.flatten
        (0...values.size).each do |i|
          if @cases.has_key?([name, i, values.size])
            @cases[[name, i, values.size]].append(values[i])
          else
            @cases[[name, i, values.size]] = [values[i]]
          end
        end
        done << name
      end
    end
  end
end