require 'whats_opt/string'

module WhatsOpt
  module OpenmdaoModule
    using WhatsOpt

    def basename
      "#{self.name.snakize}"
    end
    
    def camelname
      basename.camelize
    end    
        
    def py_modulename
      basename
    end
    
    def py_classname
      camelname
    end

    def py_filename
      "#{basename}.py"
    end

    def py_basefilename
      "#{basename}_base.py"
    end   
  end
end