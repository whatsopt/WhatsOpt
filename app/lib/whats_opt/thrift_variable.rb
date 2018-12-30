require 'whats_opt/variable'

module WhatsOpt
  
  module ThriftVariable
    
    include Variable

    class ThriftUnrecognizedTypeError < StandardError
    end
    
    def thrift_name
      self.name
        .gsub('-', '__HYPHEN__')
        .gsub(':', '__COLON__')
    end

    def thrift_type
      case self.ndim
      when 0
        (self.type == INTEGER_T)?"Integer":"Float"
      when 1 
        (self.type == INTEGER_T)?"IVector":"Vector"
      when 2
        (self.type == INTEGER_T)?"IMatrix":"Matrix"
      when 3
        (self.type == INTEGER_T)?"ICube":"Cube"
      when 4
        (self.type == INTEGER_T)?"IHyperCube":"HyperCube"
      else
        raise ThriftUnrecognizedTypeError.new("Type #{thrift_type} for variable #{self.name} 
          with nb of dim #{self.ndim} is unknown")
      end 
    end    

  end
  
  
end