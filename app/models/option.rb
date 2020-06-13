# frozen_string_literal: true

class Option < ApplicationRecord
  include WhatsOpt::PythonUtils
  belongs_to :optionizable, polymorphic: true

  before_save :sanitize

  validates :name, presence: true
  validates :value, presence: true

  def build_copy
    self.dup
  end

  def sanitize
    self.name = sanitize_pystring(self.name)
    self.value = sanitize_pystring(self.value)
  end
end
