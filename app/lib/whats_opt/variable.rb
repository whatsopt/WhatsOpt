# frozen_string_literal: true

module WhatsOpt
  module Variable
    def self.included(klass)
      klass.extend(ClassMethods)
    end

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

    INTEREST_INPUT_ROLES = [DESIGN_VAR_ROLE]
    INPUTS_ROLE = INTEREST_INPUT_ROLES + [PARAMETER_ROLE]
    OBJECTIVE_ROLES = [MIN_OBJECTIVE_ROLE, MAX_OBJECTIVE_ROLE]
    INTEREST_OUTPUT_ROLES = OBJECTIVE_ROLES + [EQ_CONSTRAINT_ROLE, INEQ_CONSTRAINT_ROLE]



    VARIABLE_ROLES = INTEREST_INPUT_ROLES + INTEREST_OUTPUT_ROLES + [PARAMETER_ROLE, RESPONSE_ROLE, STATE_VAR_ROLE]

    def dim
      @dim ||=  case self.shape
                when /\A1\z/
                  1
                when /\A\((\d+),\)\z/
                  $1.to_i
                when /\A\((\d+), (\d+)\)\z/
                  $1.to_i * $2.to_i
                when /\A\((\d+), (\d+), (\d+)\)\z/
                  $1.to_i * $2.to_i * $3.to_i
                when /\A\((\d+), (\d+), (\d+), (\d+)\)\z/
                  $1.to_i * $2.to_i * $3.to_i * $4.to_i
                else
                  raise BadShapeAttributeError.new("should be either 1, (n,), (n, m), (n, m, p) or (n, m, p, q) but found #{self.shape} for variable #{self.name}")
      end
    end

    def ndim
      @ndim ||= case self.shape
                when /\A1\z/
                  0
                when /\A\((\d+),\)\z/
                  1
                when /\A\((\d+), (\d+)\)\z/
                  2
                when /\A\((\d+), (\d+), (\d+)\)\z/
                  3
                when /\A\((\d+), (\d+), (\d+), (\d+)\)\z/
                  4
                else
                  raise BadShapeAttributeError.new("should be either 1, (n,), (n, m), (n, m, p) or (n, m, p, q) but found #{self.shape}")
      end
    end

    def reflected_io_mode
      self.is_in? ? OUT : IN
    end

    def is_out?
      self.io_mode.to_sym == OUT
    end

    def is_in?
      self.io_mode.to_sym != OUT
    end

    def reflect!(other)
      self.update(type: other.type, shape: other.shape, desc: other.desc, units: other.units, active: other.active)
      self
    end

    module ClassMethods
      def reflect_io_mode(io_mode)
        io_mode == OUT ? IN : OUT
      end

      def get_variables_attributes(cases, outvar_count = 1)
        vars = []
        sizes = {}
        cases.each do |c|
          name = c[:varname]
          if sizes.key?(name)
            sizes[name] += 1
          else
            vars << { name: name, io_mode: IN, shape: 1 }
            sizes[name] = 1
          end
        end
        vars.each do |v|
          v[:shape] = sizes[v[:name]].to_s
          v[:shape] = "(#{v[:shape]},)" if sizes[v[:name]] > 1
        end
        vars[-outvar_count..-1].each do |v|
          v[:io_mode] = OUT
        end
        vars
      end
    end
  end
end
