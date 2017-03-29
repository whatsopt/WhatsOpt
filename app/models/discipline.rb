class Discipline < ApplicationRecord
  has_many :variables
  belongs_to :multi_disciplinary_analysis
  accepts_nested_attributes_for :variables, reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true

  validates :name, presence: true

  def input_variables
    self.variables.inputs
  end

  def output_variables
    self.variables.outputs
  end

end
