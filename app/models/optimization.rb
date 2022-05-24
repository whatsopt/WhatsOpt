# frozen_string_literal: true

require "matrix"
require "whatsopt_services_types"

class Optimization < ApplicationRecord
  include Ownable

  resourcify

  OPTIMIZER_KINDS = {
    "SEGOMOE" => WhatsOpt::Services::OptimizerKind::SEGOMOE,
    "SEGMOOMOE" => WhatsOpt::Services::OptimizerKind::SEGMOOMOE
  }

  PENDING = -1
  VALID_POINT = 0
  INVALID_POINT = 1
  RUNTIME_ERROR = 2
  SOLUTION_REACHED = 3
  RUNNING = 4
  OPTIMIZER_STATUS = [VALID_POINT, INVALID_POINT, RUNTIME_ERROR, SOLUTION_REACHED, RUNNING, PENDING]

  store :config, accessors: [:xtypes, :xlimits, :n_obj, :cstr_specs, :options], coder: JSON
  store :inputs, accessors: [:x, :y, :with_optima], coder: JSON
  store :outputs, accessors: [:status, :x_suggested, :x_optima], coder: JSON

  class InputInvalid < Exception; end
  class ConfigurationInvalid < Exception; end

  after_initialize :check_optimization_config

  def create_optimizer
    unless new_record?
      if self.kind == "SEGOMOE"
        proxy.create_optimizer(Optimization::OPTIMIZER_KINDS[self.kind], self.xlimits, self.cstr_specs, self.options)
      else
        proxy.create_mixint_optimizer(Optimization::OPTIMIZER_KINDS[self.kind], self.xtypes, self.n_obj, self.cstr_specs, self.options)
      end
    end
  rescue WhatsOpt::OptimizationProxyError => err
    raise ConfigurationInvalid.new("Error in optimization proxy: '#{err}'")
  end

  def perform
    self.update!(outputs: { status: RUNNING, x_suggested: nil, x_optima: nil })
    self.proxy.tell(self.x, self.y)
    res = self.proxy.ask(self.with_optima)
    outputs = { status: res.status, x_suggested: res.x_suggested }
    outputs["x_optima"] = res.x_optima if self.with_optima
    self.update!(outputs: outputs)
  end

  def xdim
    0 if self.xlimits.blank?
    Matrix[*self.xlimits]
  end

  def proxy
    WhatsOpt::OptimizerProxy.new(id: self.id.to_s)
  end

  def check_optimization_config
    self.options = {} if self.options.blank?
    self.kind = "SEGOMOE" if self.kind.blank?
    self.n_obj = 1 if self.n_obj.blank?
    unless self.kind == "SEGOMOE" || self.kind == "SEGMOOMOE"
      raise ConfigurationInvalid.new("optimizer kind should be SEGOMOE or SEGMOOMOE, got '#{self.kind}'")
    end

    if self.kind == "SEGOMOE"
      if self.n_obj != 1
        raise ConfigurationInvalid.new("SEGOMOE is mono-objective only, got '#{self.n_obj}'")
      end

      unless self.xlimits
        raise ConfigurationInvalid.new("xlimits field should be present, got '#{self.xlimits}'")
      end

      begin
        m = Matrix[*self.xlimits]
        raise if (m.row_count < 1) || (m.column_count != 2)
      rescue Exception
        raise ConfigurationInvalid.new("xlimits should be a matrix (nx, 2), got '#{self.xlimits}'")
      end
    else 
      self.xlimits = []
    end

    if self.kind == "SEGMOOMOE"
      unless self.xtypes
        raise ConfigurationInvalid.new("xtypes field should be present, got '#{self.xtypes}'")
      end

      xtypes.each_with_index do |xt, i|
        case xt['type']
        when "float_type"
          if xt['limits'].size != 2 && xt['limits'][0].to_f != xt['limits'][0] && xt['limits'][1].to_f != xt['limits'][1]
            raise ConfigurationInvalid.new("xtype.limits should be float [lower, upper], got '#{xt['limits']}'")
          end
        when "int_type"
          if xt['limits'].size != 2 && xt['limits'][0].to_i != xt['limits'][0] && xt['limits'][1].to_i != xt['limits'][1]
            raise ConfigurationInvalid.new("xtype.limits should be int [lower, upper], got '#{xt['limits']}'")
          end
        when "ord_type"
          begin
            raise unless xt['limits'].kind_of?(Array)  
            xt['limits'].each do |l|
              raise unless l.to_i == l
            end
          rescue Exception
            raise ConfigurationInvalid.new("xtype.limits should be a list of int, got '#{xt['limits']}'")
          end
        when "enum_type"
          begin
            raise unless xt['limits'].kind_of?(Array)  
          rescue Exception
            raise ConfigurationInvalid.new("xtype.limits should be a list of string, got '#{xt['limits']}'")
          end
        else 
          raise ConfigurationInvalid.new("xtype.type should be FLOAT, INT, ORD or ENUM, got '#{xt['limits']}'")
        end
      end

    else
      self.xtypes = []
    end

    if self.cstr_specs.blank?
      self.cstr_specs = []
    else
      self.cstr_specs.each do |cspec|
        unless /^[<>=]$/.match?(cspec["type"])
          raise ConfigurationInvalid.new("Invalid constraint specification #{cspec} type should match '<>='")
        end
      end
    end
  end

  def check_optimization_inputs(params)
    unless params["x"] && params["y"]
      raise InputInvalid.new("x and y fields should be present, got #{params}")
    end
  end
end
