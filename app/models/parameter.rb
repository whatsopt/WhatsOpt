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
      _is_well_formed(init)
    end

    def lower_is_well_formed
      _is_well_formed(lower)
    end

    def upper_is_well_formed
      _is_well_formed(upper)
    end

    def _is_well_formed(val)
      return true if val.blank? || val=="nan"
      return true if /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/.match?(val)
      JSON.parse(val).kind_of?(Array)
    rescue JSON::ParserError
      Rails.logger.warn "Parameter #{self.inspect} of variable #{variable.name}(#{variable.id}) is invalid"
      errors.add(attr, "should not be badly formed (should be blank, nan, float or array)")
    end
end
