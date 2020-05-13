# frozen_string_literal: true
require 'json'

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
    return _is_well_formed(init)
  end

  def lower_is_well_formed
    return _is_well_formed(lower)
  end

  def upper_is_well_formed
    return _is_well_formed(upper)
  end

  def _is_well_formed(val)
    return true if val.blank?
    return true if val =~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
    return JSON.parse(val).kind_of?(Array)
  end

end
