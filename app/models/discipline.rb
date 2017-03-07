class Discipline < ApplicationRecord
  has_many :variables
  belongs_to :multi_disciplinary_analysis
end
