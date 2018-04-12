class Case < ApplicationRecord
  
  serialize :values
  
  belongs_to :operation
  belongs_to :variable
  
  validates :operation, presence: true
  validates :variable, presence: true

end