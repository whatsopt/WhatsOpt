require 'matrix'

class Optimization < ApplicationRecord

  include Ownable

  resourcify

  OPTIMIZER_KINDS = {
    "SEGOMOE" => WhatsOpt::Services::OptimizerKind::SEGOMOE
  }

  store :config, accessors: [:xlimits], coder: JSON  
  store :inputs, accessors: [:x, :y], coder: JSON, suffix: true
  store :outputs, accessors: [:status, :suggested], coder: JSON

  class InputInvalid < Exception; end
  class ConfigurationInvalid < Exception; end

  after_initialize :check_optimization_config

  def xdim
    0 if xlimits.blank?
    Matrix[*xlimits]
  end

  def proxy
    WhatsOpt::OptimizerProxy.new(id: id.to_s)
  end

  def check_optimization_config
    kind = 'SEGOMOE' if kind.blank?
    unless (kind == 'SEGOMOE')
      raise ConfigurationInvalid.new("optitmizer kind should be SEGOMOE, got '#{kind}'")
    end
    unless (xlimits)
      raise ConfigurationInvalid.new("xlimits field should be present, got '#{xlimits}'") 
    end
    begin
      m = Matrix[*xlimits]
      raise if m.row_count < 1 or m.column_count != 2
    rescue Exception
      raise ConfigurationInvalid.new("xlimits should be a matrix (nx, 2), got '#{xlimits}'") 
    end
  end

  def check_optimization_inputs(params)
    unless (params['x'] && params['y'])
      raise InputInvalid.new("x and y fields should be present, got #{params}")
    end
  end

end