class User < ActiveRecord::Base
  rolify
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
    
end
