class Variable < ApplicationRecord
  belongs_to :discipline

  validates :name, presence: true
end
