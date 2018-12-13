module WhatsOpt

  module Variable
    FLOAT_T   = "Float"
    INTEGER_T = "Integer"
    STRING_T = "String"
        
    IN = :in  
    OUT = :out  
    
    OBJECTIVE_PREFIX  = "objective"
    CONSTRAINT_PREFIX = "constraint"
    
    DESIGN_VAR_ROLE = "design_var"
    PARAMETER_ROLE = "parameter"
    RESPONSE_ROLE = "response"
    MIN_OBJECTIVE_ROLE = "min_objective" 
    MAX_OBJECTIVE_ROLE = "max_objective"
    EQ_CONSTRAINT_ROLE = "eq_constraint"
    INEQ_CONSTRAINT_ROLE = "ineq_constraint"
    STATE_VAR_ROLE = "state_var"
    
    VARIABLE_ROLES = [DESIGN_VAR_ROLE, PARAMETER_ROLE, MIN_OBJECTIVE_ROLE, MAX_OBJECTIVE_ROLE, EQ_CONSTRAINT_ROLE, INEQ_CONSTRAINT_ROLE, STATE_VAR_ROLE]

    def dim
      @dim ||=  case self.shape
                when /^1$/
                  1
                when /^\((\d+),\)$/ 
                  $1.to_i
                when /^\((\d+), (\d+)\)$/
                  $1.to_i * $2.to_i
                when /^\((\d+), (\d+), (\d+)\)$/
                  $1.to_i * $2.to_i * $3.to_i
                when /^\((\d+), (\d+), (\d+), (\d+)\)$/
                  $1.to_i * $2.to_i * $3.to_i * $4.to_i
                else
                  raise BadShapeAttributeError.new("should be either 1, (n,), (n, m), (n, m, p) or (n, m, p, q) but found #{self.shape}")
                end
    end

    def ndim
      @ndim ||=  case self.shape
                when /^1$/
                  0
                when /^\((\d+),\)$/ 
                  1
                when /^\((\d+), (\d+)\)$/
                  2
                when /^\((\d+), (\d+), (\d+)\)$/
                  3
                when /^\((\d+), (\d+), (\d+), (\d+)\)$/
                  4
                else
                  raise BadShapeAttributeError.new("should be either 1, (n,), (n, m), (n, m, p) or (n, m, p, q) but found #{self.shape}")
                end
    end
    
    def reflected_io_mode
      self.is_in? ? OUT : IN
    end
    
    def is_out?
      self.io_mode.to_sym==OUT
    end

    def is_in?
      self.io_mode.to_sym!=OUT
    end
        
    def reflect!(other)
      self.update(type: other.type, shape: other.shape, desc: other.desc, units: other.units, active: other.active)
      self
    end
end

end