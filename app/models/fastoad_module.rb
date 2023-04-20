# frozen_string_literal: true

class FastoadModule < ApplicationRecord
  belongs_to :fastoad_config

  validates :name, presence: true, uniqueness: true
  validates :version, presence: true
end
