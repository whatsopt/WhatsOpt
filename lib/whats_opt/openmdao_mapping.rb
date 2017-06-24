module WhatsOpt
  
  module OpenmdaoModule
    def py_classname
      self.name.parameterize.camelize
    end

    def py_filename
      "#{self.name.downcase}.py"
    end
  end
      
  module OpenmdaoVariable
    FLOAT_T = :Float
    INTEGER_T = :Integer
    
    IN = :in  
    OUT = :out  
    
    def py_varname
      self.name.parameterize.underscore
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
          "np.zeros(#{self.dim})"
        else 
          "np.zeros(#{self.dim}, dtype=np.int)"
        end
      end
    end
    
  end
  
end