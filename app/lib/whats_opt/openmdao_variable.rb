require 'whats_opt/variable'

module WhatsOpt
  
  module OpenmdaoVariable
    
    include Variable
    
    def py_varname
      name = self.name.tr('./()', '_')
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
      if self.ndim == 0
        "1"
      else
        "(#{self.dim},)"
      end
    end
    
    def default_py_value
      if self.ndim == 0
        if self.type == FLOAT_T
          "1.0"
        else 
          "1"
        end
      else
        if self.type == FLOAT_T
          "np.ones(#{self.shape})"
        else 
          "np.ones(#{self.shape}, dtype=np.int)"
        end
      end
    end
    
    def lower_py_value
      "-sys.float_info.max"
    end
    
    def upper_py_value
      "sys.float_info.max"
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