class Case < ApplicationRecord
  
  belongs_to :operation
  belongs_to :variable
  
end