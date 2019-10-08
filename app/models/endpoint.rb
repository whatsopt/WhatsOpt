# frozen_string_literal: true

class Endpoint < ApplicationRecord
  belongs_to :service, polymorphic: true
  after_initialize :ensure_port

  private
    def ensure_port
      self.port = 31400 if self.port.blank?
    end
end
