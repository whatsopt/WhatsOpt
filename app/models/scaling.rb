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
    return _is_well_formed(ref)
  end

  def ref0_is_well_formed
    return _is_well_formed(ref0)
  end

  def res_ref_is_well_formed
    return _is_well_formed(res_ref)
  end

  def _is_well_formed(val)
    return true if val.blank?
    return true if val =~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
    return JSON.parse(val).kind_of?(Array)
  end
end
