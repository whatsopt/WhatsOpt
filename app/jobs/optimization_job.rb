# frozen_string_literal: true

class OptimizationJob < ActiveJob::Base
  def perform(optim)
    optim.perform
  end
end
