# frozen_string_literal: true

require "json"

class Parameter < ApplicationRecord
  belongs_to :variable

  validates :variable, presence: true
  validate :init_is_well_formed
  validate :lower_is_well_formed
  validate :upper_is_well_formed

  def nullified?
    init.blank? && lower.blank? && upper.blank?
  end

  private
    def init_is_well_formed
      _is_well_formed(:init, init)
    end

    def lower_is_well_formed
      _is_well_formed(:lower, lower)
    end

    def upper_is_well_formed
      _is_well_formed(:upper, upper)
    end

    def _is_well_formed(name, val)
      return true if val.blank? || val=="nan"
      return true if val =~ /^np\.(.*)/  # authorize numpy whatever operations
      return true if /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/.match?(val)
      # nan values are accepted in order to accept parameters generated from pushed OpenMDAO code
      # example CICAV BWB analysis
      # accept array or matrices of nans only, dim 3 or 4 not handled (yagni)
      return true if /^\[(\[?(nan,?\s*)*\]?,?\s*)*\]$/.match?(val)
      JSON.parse(val).kind_of?(Array)
    rescue JSON::ParserError
      Rails.logger.warn "Parameter #{self.inspect} of variable #{variable.name}(#{variable.id}) is invalid"
      errors.add(name, "should not be badly formed (should be blank, nan, float or array)")
    end
end
