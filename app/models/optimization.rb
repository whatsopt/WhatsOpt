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

  OPTIMIZATION_ERROR = -2
  PENDING = -1
  VALID_POINT = 0
  INVALID_POINT = 1
  RUNTIME_ERROR = 2
  SOLUTION_REACHED = 3
  RUNNING = 4
  OPTIMIZER_STATUS = [VALID_POINT, INVALID_POINT, RUNTIME_ERROR, SOLUTION_REACHED, RUNNING, PENDING, OPTIMIZATION_ERROR]

  store :config, accessors: [:xtypes, :xlimits, :n_obj, :cstr_specs, :options], coder: JSON
  store :inputs, accessors: [:x, :y, :with_best], coder: JSON
  store :outputs, accessors: [:status, :x_suggested, :x_best, :y_best, :err_msg], coder: JSON

  scope :owned_by, ->(user) { with_role(:owner, user) }

  class OptimizationError < Exception; end
  
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
    log_error("#{err}: #{err.message}")  # do not fail in case of proxy error, let the client handle the error
  end

  def perform
    self.update!(outputs: { status: RUNNING, x_suggested: nil, x_best: nil, y_best: nil })
    self.proxy.tell(self.x, self.y)
    res = self.proxy.ask(self.with_best)
    outputs = { status: res.status, x_suggested: res.x_suggested }
    outputs["x_best"] = res.x_best if self.with_best
    outputs["y_best"] = res.y_best if self.with_best
    self.update!(outputs: outputs)
  rescue WhatsOpt::OptimizationProxyError, WhatsOpt::Services::OptimizerException => err
    log_error("#{err}: #{err.message}") # asynchronous: just set error state and log the error
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
      raise_error("optimizer kind should be SEGOMOE or SEGMOOMOE, got '#{self.kind}'")
    end

    if self.kind == "SEGOMOE"
      if self.n_obj != 1
        raise_error("SEGOMOE is mono-objective only, got '#{self.n_obj}'")
      end

      unless self.xlimits
        raise_error("xlimits field should be present, got '#{self.xlimits}'")
      end

      begin
        m = Matrix[*self.xlimits]
        raise if (m.row_count < 1) || (m.column_count != 2)
      rescue Exception
        raise_error("xlimits should be a matrix (nx, 2), got '#{self.xlimits}'")
      end
    else 
      self.xlimits = []
    end

    if self.kind == "SEGMOOMOE"
      unless self.xtypes
        raise_error("xtypes field should be present, got '#{self.xtypes}'")
      end

      xtypes.each_with_index do |xt, i|
        case xt['type']
        when "float_type"
          if xt['limits'].size != 2 && xt['limits'][0].to_f != xt['limits'][0] && xt['limits'][1].to_f != xt['limits'][1]
            raise_error("xtype.limits should be float [lower, upper], got '#{xt['limits']}'")
          end
        when "int_type"
          if xt['limits'].size != 2 && xt['limits'][0].to_i != xt['limits'][0] && xt['limits'][1].to_i != xt['limits'][1]
            raise_error("xtype.limits should be int [lower, upper], got '#{xt['limits']}'")
          end
        when "ord_type"
          begin
            raise unless xt['limits'].kind_of?(Array)  
            xt['limits'].each do |l|
              raise unless l.to_i == l
            end
          rescue Exception
            raise_error("xtype.limits should be a list of int, got '#{xt['limits']}'")
          end
        when "enum_type"
          begin
            raise unless xt['limits'].kind_of?(Array)  
          rescue Exception
            raise_error("xtype.limits should be a list of string, got '#{xt['limits']}'")
          end
        else 
          raise_error("xtype.type should be FLOAT, INT, ORD or ENUM, got '#{xt['limits']}'")
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
          raise_error("Invalid constraint specification #{cspec} type should match '<>='")
        end
      end
    end
  end

  def check_optimization_inputs(params)
    unless params["x"] && params["y"]
      raise_error("x and y fields should be present, got #{params}")
    end
  end

  def log_error(err_msg)
    update!(status: OPTIMIZATION_ERROR, err_msg: err_msg)
    Rails.logger.error "Optimization Error: #{err_msg}"
  end

  def raise_error(err_msg)
    raise OptimizationError.new(err_msg)
  end

  def nb_points
    self.inputs.empty? ? "0" : self.inputs["x"].length
  end

  
end
