class Variable < ApplicationRecord
  belongs_to :discipline

  validates :name, presence: true

  scope :inputs, -> { where(io_mode: 'in') }
  scope :outputs, -> { where(io_mode: 'out') }
end
