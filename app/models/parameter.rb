class Parameter < ApplicationRecord
  belongs_to :variable
  
  validates :variable, presence: true
     
  def nullified?
    init.blank? && lower.blank? && upper.blank?
  end
  
end
