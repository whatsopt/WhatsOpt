# frozen_string_literal: true

class Option < ApplicationRecord
  belongs_to :optionizable, polymorphic: true

  validates :name, presence: true
  validates :value, presence: true 

  def build_copy
    self.dup
  end
end
