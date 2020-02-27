# frozen_string_literal: true

class Api::ApiController < ActionController::Base
  include Response
  include ExceptionHandler
  include WhatsOpt::Version

  # Authorization
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, except: [:index], unless: :api_docs_controller? 
  after_action :verify_policy_scoped, only: [:index], unless: :api_docs_controller? 

  respond_to :json

  # API is protected through Api Key authentication not CSRF
  protect_from_forgery with: :null_session

  before_action :authenticate, unless: :api_docs_controller?
  before_action :check_wop_version 

  attr_reader :current_user

  def whatsopt_url
    request.base_url + Rails.application.config.relative_url_root.to_s
  end

  private
    def authenticate
      authenticate_or_request_with_http_token('WhatsOpt') do |token, options|
        @current_user = User.where(api_key: token).first
      end
    end

    def user_not_authenticated
      json_response({ message: "Unauthenticated" }, :unauthorized)
    end

    def user_not_authorized
      json_response({ message: "Unauthorized" }, :unauthorized)
    end

    def api_docs_controller?
      controller_name == 'api_docs'
    end

    def wop_agent_version
      $1 if request.headers['User-Agent'] =~ /^wop\/(.*)/
    end

    def wop_agent_version?
      p wop_agent_version
      !!wop_agent_version
    end

    def check_wop_version
      p "COUCOU"
      check_minimal_wop_version(wop_agent_version)
    end
end
