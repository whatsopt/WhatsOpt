class Scaling < ApplicationRecord
  belongs_to :variable
  
  validates :variable, presence: true

  def nullified?
    ref.blank? && ref0.blank? && res_ref.blank?
  end
end
