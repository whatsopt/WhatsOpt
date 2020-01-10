class Distribution < ApplicationRecord

  DISTRIBUTIONS = %w(Normal Beta Gamma Uniform)

  has_many :options, as: :optionizable 

  validates :kind, presence: true, allow_blank: false

end
