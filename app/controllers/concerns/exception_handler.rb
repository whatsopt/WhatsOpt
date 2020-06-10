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
      json_response({ message: e.message }, :unprocessable_entity)
    end

    rescue_from Operation::ForbiddenRemovalError do |e|
      Rails.logger.error "Operation forbidden removal: " + e.message
      json_response({ message: e.message }, :forbidden)
    end

    rescue_from WhatsOpt::Version::WopVersionMismatchException do |e|
      Rails.logger.error "Version: " + e.message
      json_response({ message: e.message }, :forbidden)
    end

    rescue_from Optimization::ConfigurationInvalid do |e|
      Rails.logger.error "Invalid configuration : " + e.message
      json_response({ message: e.message }, :bad_request)
    end

    rescue_from Optimization::InputInvalid do |e|
      Rails.logger.error "Invalid inputs : " + e.message
      json_response({ message: e.message }, :bad_request)
    end

    # Never catch here as the optimizer computation is asynchronous now
    # rescue_from WhatsOpt::Services::OptimizerException do |e|
    #   Rails.logger.error "Optimization error : " + e.message
    #   json_response({ message: e.message }, :unprocessable_entity)
    # end
  end
end
