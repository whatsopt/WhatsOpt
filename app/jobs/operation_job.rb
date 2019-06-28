# frozen_string_literal: true

class OperationJob < ActiveJob::Base
  def perform(ope)
    ope.perform
  end
end
