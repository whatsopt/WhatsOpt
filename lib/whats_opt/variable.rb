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
  end

end