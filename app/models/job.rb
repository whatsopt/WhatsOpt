# frozen_string_literal: true

class Job < ApplicationRecord
  TERMINATION_STATUSES = %w[DONE FAILED KILLED].freeze
  STATUSES = %w[PENDING RUNNING] + TERMINATION_STATUSES

  belongs_to :operation

  after_initialize :ensure_defaults

  def ensure_defaults
    self.status ||= "PENDING"
    self.pid ||= -1
    self.log ||= ""
    self.log_count ||= 0
  end
end
