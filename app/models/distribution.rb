# frozen_string_literal: true

class Distribution < ApplicationRecord
  DISTRIBUTIONS = %w(Normal Beta Gamma Uniform)

  belongs_to :variable

  has_many :options, as: :optionizable, dependent: :destroy
  accepts_nested_attributes_for :options, reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true

  validates :kind, presence: true, allow_blank: false
  validates :kind, inclusion: { in: DISTRIBUTIONS }

  def nullified?
    kind=="none" || kind.blank?
  end

  def self.uniform_attrs(a, b)
    {
      kind: "Uniform",
      options_attributes: [{ name: "a", value: a.to_s }, { name: "b", value: b.to_s }]
    }
  end

  def self.normal_attrs(mu, sigma)
    {
      kind: "Normal",
      options_attributes: [{ name: "mu", value: mu.to_s }, { name: "sigma", value: sigma.to_s }]
    }
  end
end
