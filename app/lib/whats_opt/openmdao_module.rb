require 'whats_opt/string'

module WhatsOpt
  module OpenmdaoModule
    using WhatsOpt

    cattr_accessor :root_modulename

    def basename
      "#{self.name.snakize}"
    end
    
    def camelname
      basename.camelize
    end    
        
    def py_modulename
      basename
    end

    def py_full_modulename
      namespace = self.path.map{|a| a.basename}
      @@root_modulename ||= basename
      idx = namespace.index(root_modulename)
      namespace.shift(idx+1) if idx
      namespace.join('.')
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

