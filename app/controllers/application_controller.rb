# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Authentication
  rescue_from DeviseLdapAuthenticatable::LdapException, with: :user_not_authenticated
  before_action :authenticate_user!

  # Authorization
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, except: [:index], unless: :devise_controller?
  after_action :verify_policy_scoped, only: [:index], unless: :devise_controller?

  private
    def user_not_authenticated
      flash[:error] = "LDAP Authentication failed."
      redirect_to root_path
    end

    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      redirect_to root_path
    end
end
