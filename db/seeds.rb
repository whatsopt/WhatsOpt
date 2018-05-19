# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def create_user(params) 
  u = User.find_by_login(params[:login])
  if u
    puts "User #{params[:login]} already in database" 
  else
    puts "Creating user #{params[:login]}" 
    u = User.create! do |u|
      u.login                 = params[:login]
      u.email                 = params[:email]
      u.password              = "!" << params[:login]
      u.password_confirmation = "!" << params[:login]
    end
  end
  u
end

# Admin
u=create_user(login: "admin", 
              email: "admin@onera.fr")
u.add_role(:admin)
u.save!

# Onera 
u = create_user(login: "rlafage",
                email: "test@onera.fr")
u.save!
