# frozen_string_literal: true

module ExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      Rails.logger.error "Record not found : " + e.message
      json_response({ message: e.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      Rails.logger.error "Record invalid : " + e.message
      json_response({ message: e.message }, :unprocessable_content)
    end

    rescue_from WhatsOpt::Version::WopVersionMismatchException do |e|
      Rails.logger.error "Version: " + e.message
      json_response({ message: e.message }, :forbidden)
    end

    rescue_from Api::StaleObjectError do |e|
      Rails.logger.error "Stale Object: " + e.message
      json_response({ message: e.message }, :conflict)
    end
  end
end
