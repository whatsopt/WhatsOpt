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
      u.password              = "#{params[:login].capitalize}2022!"
      u.password_confirmation = "#{params[:login].capitalize}2022!"
    end
  end
  u
end

# WhatsOpt generic user
u=create_user(login: "whatsopt", 
              email: "whatsopt@example.com")
u.save!

# Admin
# u=create_user(login: "admin", 
#               email: "admin@example.com")
# u.add_role(:admin)
# u.save!

