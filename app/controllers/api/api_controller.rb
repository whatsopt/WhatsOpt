class Api::ApiController < ActionController::Base
  include Response
  include ExceptionHandler

  # Authorization
  include Pundit 
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, except: [:index] 
  after_action :verify_policy_scoped, only: [:index]
     
  respond_to :json
  
  protect_from_forgery with: :null_session
 
  before_action :authenticate
  
  def current_user
    @current_user
  end
 
  private
  
  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @current_user = User.where(api_key: token).first
    end
  end
end
