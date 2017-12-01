class Api::ApiController < ActionController::Base
  respond_to :json
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
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
