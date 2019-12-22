# frozen_string_literal: true

class Job < ApplicationRecord
  SUCCESS_STATUSES = %w[DONE ASSUME_DONE DONE_OFFLINE].freeze
  TERMINATION_STATUSES = %w[FAILED KILLED] + SUCCESS_STATUSES
  STATUSES = %w[PENDING RUNNING] + TERMINATION_STATUSES

  belongs_to :operation

  after_initialize :ensure_defaults

  def started?
    status == "RUNNING"
  end

  def success?
    SUCCESS_STATUSES.include?(status)
  end

  def ensure_defaults
    self.status ||= "PENDING"
    self.pid ||= -1
    self.log ||= ""
    self.log_count ||= 0
  end
end
