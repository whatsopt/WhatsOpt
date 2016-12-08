class User < ActiveRecord::Base
  rolify
  
  devise :database_authenticatable, :ldap_authenticatable, :trackable, :validatable, :timeoutable
  #devise :ldap_authenticatable, :trackable, :validatable, :timeoutable

  before_create :generate_api_key

  # Used to create user on first LDAP authentication 
  def ldap_before_save
    self.email = Devise::LDAP::Adapter.get_ldap_param(self.login, "mail").first
  end

  private
  
  def generate_api_key
    begin
      self.api_key = SecureRandom.hex
    end while self.class.exists?(api_key: api_key)
  end
  
end
