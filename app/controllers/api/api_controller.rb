class Api::ApiController < ActionController::Base
  respond_to :json
 
  before_action :authenticate
 
  private
  
  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @user = User.where(api_key: token).first
    end
  end
end
