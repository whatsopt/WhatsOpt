require 'whats_opt/string'

module WhatsOpt

  module OpenmdaoModule
    using WhatsOpt

    def file_basename
      "#{self.name.snakize}"
    end
        
    def py_modulename
      "#{self.name.snakize}"
    end
    
    def py_classname
      self.name.snakize.camelize
    end

    def py_filename
      "#{self.py_modulename}.py"
    end
    
  end

end