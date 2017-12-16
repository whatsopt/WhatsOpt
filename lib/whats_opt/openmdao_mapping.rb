module WhatsOpt

  refine String do
    def snakize
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr('-', '_').
      gsub(/\s/, '_').
      gsub(/__+/, '_').
      downcase
    end
  end
    
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
      
  module Variable
    FLOAT_T   = "Float"
    INTEGER_T = "Integer"
        
    IN = :in  
    OUT = :out  
    
    OBJECTIVE_PREFIX  = "obj"
    CONSTRAINT_PREFIX = "cstr"
  end
  
  module OpenmdaoVariable
    include Variable
    
    def py_varname
      self.name.downcase
    end
    
    def py_desc
      desc = self.desc
      desc += " (#{self.units})"
      desc
    end
    
    def default_py_type
      if self.type == INTEGER_T
        "np.int"
      else
        "np.float"
      end
    end
      
    def default_py_shape
      if self.dim == 1
        "1"
      else
        "(#{self.dim},)"
      end
    end
    
    def default_py_value
      if self.dim == 1
        if self.type == FLOAT_T
          "0.0"
        else 
          "0"
        end
      else
        if self.type == FLOAT_T
          "np.zeros(#{self.shape})"
        else 
          "np.zeros(#{self.shape}, dtype=np.int)"
        end
      end
    end
    
    def escaped_desc
      s = ""
      unless self.desc.blank? 
        s = self.desc.gsub("'", "\\\\'")
      end
      s
    end
    
  end
  
end