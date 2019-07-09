# frozen_string_literal: true

class MetaModel < ApplicationRecord
  belongs_to :analysis
  belongs_to :operation

  has_many :surrogates, dependent: :destroy

  validates :analysis, presence: true

  after_initialize :_set_defaults

  MATRIX_FORMAT = 'matrix'
  FORMATS = [MATRIX_FORMAT]

  def build_surrogates
    analysis.response_variables.each do |v|
      (0...v.dim).each do |index|
        surrogates.build(variable: v, coord_index: index-1)
      end
    end
  end

  def predict(values)
    res = []
    surrogates.each do |surr|

    end
    res
  end

private

  def _set_defaults
    self.default_surrogate_kind = Surrogate::SURROGATES[0] if self.default_surrogate_kind.blank? 
  end
  
end
