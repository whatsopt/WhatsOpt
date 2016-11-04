class User < ActiveRecord::Base
  rolify
  
  devise :database_authenticatable, :trackable, :validatable, :timeoutable

  before_create :generate_api_key

  private
  
  def generate_api_key
    begin
      self.api_key = SecureRandom.hex
    end while self.class.exists?(api_key: api_key)
  end
  
end
