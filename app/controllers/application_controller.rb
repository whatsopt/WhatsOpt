# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Authentication
  rescue_from DeviseLdapAuthenticatable::LdapException, with: :user_not_authenticated
  before_action :authenticate_user!, unless: :api_docs_controller?

  # Authorization
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, except: [:index], unless: :no_authorization_verify?
  after_action :verify_policy_scoped, only: [:index], unless: :no_authorization_verify?

  private
    def user_not_authenticated
      flash[:error] = "LDAP Authentication failed."
      redirect_to root_path
    end

    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      redirect_to root_path
    end

    def api_docs_controller?
      controller_name == 'api_docs'
    end

    def no_authorization_verify?
      devise_controller? || api_docs_controller?
    end
end
