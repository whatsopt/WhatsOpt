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
    PLAIN_ROLE = "plain"
    
    VARIABLE_ROLES = [DESIGN_VAR_ROLE, PARAMETER_ROLE, MIN_OBJECTIVE_ROLE, MAX_OBJECTIVE_ROLE, EQ_CONSTRAINT_ROLE, INEQ_CONSTRAINT_ROLE, PLAIN_ROLE]

    def dim
      @dim ||=  case self.shape
                when /^1$/
                  $1.to_i
                when /^\((\d+),\)$/ 
                  $1.to_i
                when /^\((\d+), (\d+)\)$/
                  $1.to_i * $2.to_i
                when /^\((\d+), (\d+), (\d+)\)$/
                  $1.to_i * $2.to_i * $3.to_i
                else
                  raise BadShapeAttributeError.new("should be either 1, (n,), (n, m) or (n, m, p) but found #{self.shape}")
                end
    end

    def ndim
      @dim ||=  case self.shape
                when /^1$/
                  0
                when /^\((\d+),\)$/ 
                  1
                when /^\((\d+), (\d+)\)$/
                  2
                when /^\((\d+), (\d+), (\d+)\)$/
                  3
                else
                  raise BadShapeAttributeError.new("should be either 1, (n,), (n, m) or (n, m, p) but found #{self.shape}")
                end
    end
    
end

end