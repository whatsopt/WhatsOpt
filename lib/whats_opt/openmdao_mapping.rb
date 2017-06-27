class String
  def snakize
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr('-', '_').
    gsub(/\s/, '_').
    gsub(/__+/, '_').
    downcase
  end
end

module WhatsOpt
  
  module OpenmdaoModule
    def py_classname
      self.name.snakize.camelize
    end

    def py_filename
      "#{self.name.snakize}.py"
    end
  end
      
  module OpenmdaoVariable
    FLOAT_T = :Float
    INTEGER_T = :Integer
    
    IN = :in  
    OUT = :out  
    
    def py_varname
      self.name.downcase
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