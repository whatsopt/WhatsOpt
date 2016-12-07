# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'json'

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
      p.description = params[:description]
    end
  end
  project
end

def create_study(params) 
  puts "Creating study of Project #{params[:project_id]}" 
  study = Study.create! do |p|
    p.project_id = params[:project_id]
    p.name = params[:name]
    p.attachments << Attachment.create!(params[:attachment_attributes])
  end
end

def create_run(params) 
  puts "Creating run of Study #{params[:study_id]}" 
  run = Run.create! do |p|
    p.study_id = params[:study_id]
  end
end


# Admin
u=create_user(login: "admin", 
              email: "admin@onera.fr")
u.add_role(:admin)
u.save!

# Project
project_scratch = create_project(name:"Scratch", description: "Default project to start with ")

# Study
study_test = create_study(name:"Study Example", project_id:project_scratch.id,
                          attachment_attributes: {category: 'Notebook',
                                                  data: File.new(File.expand_path("../Matplotlib.ipynb", __FILE__))})

# Onera 
u = create_user(login: "rlafage",
                email: "test@onera.fr")
u.add_role(:manager, project_scratch)
u.save!
