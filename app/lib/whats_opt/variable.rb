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
                when /\A1\z/
                  1
                when /\A\((\d+)L?,\)\z/ 
                  $1.to_i
                when /\A\((\d+)L?, (\d+)L?\)\z/
                  $1.to_i * $2.to_i
                when /\A\((\d+)L?, (\d+)L?, (\d+)L?\)\z/
                  $1.to_i * $2.to_i * $3.to_i
                when /\A\((\d+)L?, (\d+)L?, (\d+)L?, (\d+)L?\)\z/
                  $1.to_i * $2.to_i * $3.to_i * $4.to_i
                else
                  raise BadShapeAttributeError.new("should be either 1, (n,), (n, m), (n, m, p) or (n, m, p, q) but found #{self.shape} for variable #{self.name}")
                end
    end

    def ndim
      @ndim ||=  case self.shape
                when /\A1\z/
                  0
                when /\A\((\d+)L?,\)\z/ 
                  1
                when /\A\((\d+)L?, (\d+)L?\)\z/
                  2
                when /\A\((\d+)L?, (\d+)L?, (\d+)L?\)\z/
                  3
                when /\A\((\d+)L?, (\d+)L?, (\d+)L?, (\d+)L?\)\z/
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