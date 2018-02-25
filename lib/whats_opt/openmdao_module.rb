require 'whats_opt/string'

module WhatsOpt

  module OpenmdaoModule
    using WhatsOpt

    def to_basename
      "#{self.name.snakize}"
    end
        
    def py_modulename
      "#{self.to_basename}"
    end
    
    def py_classname
      self.name.snakize.camelize
    end

    def py_filename
      "#{self.py_modulename}.py"
    end

    def py_basefilename
      "#{self.py_modulename}_base.py"
    end
        
  end

end