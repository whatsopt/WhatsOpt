require 'matrix'
require 'whatsopt_services_types'

class Optimization < ApplicationRecord

  include Ownable

  resourcify

  OPTIMIZER_KINDS = {
    "SEGOMOE" => WhatsOpt::Services::OptimizerKind::SEGOMOE
  }

  store :config, accessors: [:xlimits], coder: JSON  
  store :inputs, accessors: [:x, :y], coder: JSON
  store :outputs, accessors: [:status, :x_suggested], coder: JSON

  class InputInvalid < Exception; end
  class ConfigurationInvalid < Exception; end

  after_initialize :check_optimization_config

  def create_optimizer
    unless new_record?  
      proxy.create_optimizer(Optimization::OPTIMIZER_KINDS[kind], {xlimits: xlimits})
    end
  end

  def xdim
    0 if self.xlimits.blank?
    Matrix[*self.xlimits]
  end

  def proxy
    WhatsOpt::OptimizerProxy.new(id: self.id.to_s)
  end

  def check_optimization_config
    kind = 'SEGOMOE' if kind.blank? 
    unless (self.kind == 'SEGOMOE')
      raise ConfigurationInvalid.new("optimizer kind should be SEGOMOE, got '#{self.kind}'")
    end
    unless (self.xlimits)
      raise ConfigurationInvalid.new("xlimits field should be present, got '#{self.xlimits}'") 
    end
    begin
      m = Matrix[*self.xlimits]
      raise if m.row_count < 1 or m.column_count != 2
    rescue Exception
      raise ConfigurationInvalid.new("xlimits should be a matrix (nx, 2), got '#{self.xlimits}'") 
    end
  end

  def check_optimization_inputs(params)
    unless (params['x'] && params['y'])
      raise InputInvalid.new("x and y fields should be present, got #{params}")
    end
  end

end