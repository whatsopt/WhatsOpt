# pretty much exclusively created for fixtures to work
class UsersRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
end