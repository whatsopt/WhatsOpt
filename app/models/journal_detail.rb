# frozen_string_literal: true

class JournalDetail < ApplicationRecord

  belongs_to :journal

  after_initialize :ensure_default_values

  private

  def ensure_default_values
    self.old_value = "" if self.old_value.blank?
    self.value = "" if self.value.blank?
  end
    
end