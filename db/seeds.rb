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

def create_project(params) 
  project = Project.find_by_name(params[:name])
  if project
    puts "Project #{params[:name]} already in database" 
  else
    puts "Creating project #{params[:name]}" 
    project = Project.create! do |p|
      p.name = params[:name]
    end
  end
  project
end

# Admin
u=create_user(login: "admin", 
              email: "admin@onera.fr")
u.add_role(:admin)
u.save!

# Project
project_test = create_project(name:"Test", description: "Project Test")

# Onera 
u = create_user(login: "rlafage",
                email: "test@onera.fr")
u.add_role(:manager, project_test)
u.save!
