require 'whats_opt/string'

module WhatsOpt

  module OpenmdaoModule
    using WhatsOpt

    def to_basename
      "#{self.name.snakize}"
    end
    
    def file_basename
      "#{self.to_basename}_base"
    end
        
    def py_modulename
      "#{self.to_basename}_base"
    end
    
    def py_classname
      self.name.snakize.camelize+"Base"
    end

    def py_filename
      "#{self.py_modulename}.py"
    end
    
  end

end