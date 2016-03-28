# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def create_user(params) 
  if User.find_by_login(params[:login])
    puts "User #{params[:login]} already in database" 
  else
    puts "Creating user #{params[:login]}" 
    User.create! do |u|
      u.login                 = params[:login]
      u.email                 = params[:email]
      u.password              = "!" << params[:login]
      u.password_confirmation = "!" << params[:login]
      u.roles_mask            = params[:roles_mask]
    end
  end
end

# Admin
create_user(:login      => "admin", 
            :email      => "rlafage@onera.fr",
            :roles_mask => 1)

# Onera 
create_user(:login      => "rlafage",
            :email      => "remi.lafage@onera.fr",
            :roles_mask => 2)
