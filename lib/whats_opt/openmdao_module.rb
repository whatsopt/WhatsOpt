require 'whats_opt/string'

module WhatsOpt

  module OpenmdaoModule
    using WhatsOpt

    def basename
      "#{self.name.snakize}"
    end
        
    def py_modulename
      "#{self.basename}"
    end
    
    def py_classname
      self.basename.camelize
    end

    def py_filename
      "#{self.basename}.py"
    end

    def py_basefilename
      "#{self.basename}_base.py"
    end
        
  end

end