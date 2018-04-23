class Case < ApplicationRecord
  
  serialize :values
  
  belongs_to :operation
  belongs_to :variable
  
  validates :operation, presence: true
  validates :variable, presence: true

  def nb_of_points
    values.size
  end
  
end