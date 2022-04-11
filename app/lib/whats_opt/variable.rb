# frozen_string_literal: true

module WhatsOpt
  module Variable

    class BadShapeAttributeError < StandardError
    end
    class VectorizedShapeError < StandardError
    end

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
    UNCERTAIN_VAR_ROLE = "uncertain_var"

    RESPONSE_ROLE = "response"
    RESPONSE_OF_INTEREST_ROLE = "response_of_interest"
    MIN_OBJECTIVE_ROLE = "min_objective"
    MAX_OBJECTIVE_ROLE = "max_objective"
    EQ_CONSTRAINT_ROLE = "eq_constraint"
    NEG_CONSTRAINT_ROLE = "ineq_constraint"
    POS_CONSTRAINT_ROLE = "pos_constraint"
    CONSTRAINT_ROLE = "constraint"
    STATE_VAR_ROLE = "state_var"

    INTEREST_INPUT_ROLES = [DESIGN_VAR_ROLE, UNCERTAIN_VAR_ROLE]
    INPUT_ROLES = INTEREST_INPUT_ROLES + [PARAMETER_ROLE]
    OBJECTIVE_ROLES = [MIN_OBJECTIVE_ROLE, MAX_OBJECTIVE_ROLE]
    INTEREST_OUTPUT_ROLES = OBJECTIVE_ROLES + [EQ_CONSTRAINT_ROLE, NEG_CONSTRAINT_ROLE, POS_CONSTRAINT_ROLE, CONSTRAINT_ROLE, RESPONSE_OF_INTEREST_ROLE]
    OUTPUT_ROLES = INTEREST_OUTPUT_ROLES + [RESPONSE_ROLE]
    CONSTRAINT_ROLES = [EQ_CONSTRAINT_ROLE, NEG_CONSTRAINT_ROLE, POS_CONSTRAINT_ROLE, CONSTRAINT_ROLE]

    VARIABLE_ROLES = INTEREST_INPUT_ROLES + INTEREST_OUTPUT_ROLES + [PARAMETER_ROLE, RESPONSE_ROLE, STATE_VAR_ROLE]

    def dim
      @dim ||=  case self.shape
                when /\A\s*1\s*\z/
                  1
                when /\A\s*\(\s*(\d+)\s*,\s*\)\s*\z/
                  $1.to_i
                when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
                  $1.to_i * $2.to_i
                when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
                  $1.to_i * $2.to_i * $3.to_i
                when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
                  $1.to_i * $2.to_i * $3.to_i * $4.to_i
                else
                  raise BadShapeAttributeError.new("Shape should be either 1, (n,), (n, m), (n, m, p) or (n, m, p, q) but got '#{self.shape}' for variable #{self.name}")
      end
    end

    def ndim
      @ndim ||= case self.shape
                when /\A\s*1\s*\z/
                  0
                when /\A\s*\(\s*(\d+)\s*,\s*\)\s*\z/
                  1
                when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
                  2
                when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
                  3
                when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
                  4
                else
                  raise BadShapeAttributeError.new("Shape should be either 1, (n,), (n, m), (n, m, p) or (n, m, p, q) but got '#{self.shape}' for variable #{self.name}")
      end
    end

    def vectorized_shape
      case self.ndim
      when 0
        "(1, 1)"
      when 1
        "(1, #{self.dim})"
      when 2
        if self.shape =~ /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/ && $1=="1"
          self.shape
        else
          raise VectorizedShapeError.new("Cannot get a vectorized version of '#{self.name}'variable of shape #{self.shape}")
        end
      else
        raise VectorizedShapeError.new("Cannot get a vectorized version of '#{self.name}' variable of shape #{self.shape}")
      end
    end

    def first_dim
      @first_dim ||=  case self.shape
      when /\A\s*1\s*\z/
        0
      when /\A\s*\(\s*(\d+)\s*,\s*\)\s*\z/
        $1.to_i
      when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
        $1.to_i
      when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
        $1.to_i
      when /\A\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*\z/
        $1.to_i
      else
        raise BadShapeAttributeError.new("Shape should be either 1, (n,), (n, m), (n, m, p) or (n, m, p, q) but got '#{self.shape}' for variable #{self.name}")
      end
    end

    def reflected_io_mode
      self.is_in? ? OUT : IN
    end

    def is_scalar?
      type != STRING_T && ndim == 0
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
      def vars_dim(vars)
        vars.inject(0) { |s, v| s + v.dim }
      end

      def reflect_io_mode(io_mode)
        io_mode == OUT ? IN : OUT
      end

      def get_varattrs_from_caseattrs(cases, outvar_count = 1)
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
