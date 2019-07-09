# frozen_string_literal: true
require 'matrix'

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
      yvals = surr.predict(values)
      if res.empty?
        res = yvals.map{|y| [y]}
      else
        yvals.each_with_index do |y, i|
          res[i] << y
        end
      end
    end
    res
  end

  def training_input_values
    Matrix.columns(operation.input_cases.map(&:values)).to_a
  end

  def training_output_values(varname, coord_index)
    p varname, coord_index
    operation.cases.where(coord_index: coord_index).joins(:variable).where(variables: {name: varname}).take.values
  end

private

  def _set_defaults
    self.default_surrogate_kind = Surrogate::SURROGATES[0] if self.default_surrogate_kind.blank? 
  end
  
end
