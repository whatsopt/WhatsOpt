# frozen_string_literal: true

class Scaling < ApplicationRecord
  belongs_to :variable

  validates :variable, presence: true
  validate :ref_is_well_formed
  validate :ref0_is_well_formed
  validate :res_ref_is_well_formed

  def nullified?
    ref.blank? && ref0.blank? && res_ref.blank?
  end

  private
    def ref_is_well_formed
      _is_well_formed(ref, :ref)
    end

    def ref0_is_well_formed
      _is_well_formed(ref0, :ref0)
    end

    def res_ref_is_well_formed
      _is_well_formed(res_ref, :res_ref)
    end

    def _is_well_formed(val, attr)
      return true if val.blank?
      return true if /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/.match?(val)
      JSON.parse(val).kind_of?(Array)
    rescue JSON::ParserError
      Rails.logger.warn "Scaling #{self.inspect} of variable #{variable.name}(#{variable.id}) is invalid"
      errors.add(attr, "should not be badly formed (should be blank, float or array)")
    end
end
