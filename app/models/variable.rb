class Variable < ApplicationRecord
  self.inheritance_column = :disable_inheritance
  belongs_to :discipline

  validates :name, presence: true

  scope :inputs, -> { where(io_mode: 'in') }
  scope :outputs, -> { where(io_mode: 'out') }
end
