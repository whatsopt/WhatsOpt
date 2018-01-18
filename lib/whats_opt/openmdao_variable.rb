require 'whats_opt/variable'

module WhatsOpt
  
  module OpenmdaoVariable
    
    include Variable
    
    def py_varname
      name = self.fullname.tr('./', '_')
      name.downcase
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