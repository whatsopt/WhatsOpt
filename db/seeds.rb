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
  study = Study.find_by_project_id(params[:project_id])
  if study
    puts "A study already exists in Project #{params[:project_id]} in database" 
  else
    puts "Creating study of Project #{params[:project_id]}" 
    study = Study.create! do |p|
      p.project_id = params[:project_id]
      p.attachments << Attachment.create!(params[:attachment_attributes])
    end
  end
  study
end

def create_run(params) 
  puts "Creating run of Study #{params[:study_id]}" 
  run = Run.create! do |p|
    p.study_id = params[:study_id]
  end
end

def create_mda(params) 
  mda = MultiDisciplinaryAnalysis.find_by_name(params[:name])
  if mda
    puts "MDA #{params[:name]} already in database" 
  else
    puts "Creating MDA #{params[:name]}" 
    mda = MultiDisciplinaryAnalysis.create!(params)
  end
  mda
end

# Admin
u=create_user(login: "admin", 
              email: "admin@onera.fr")
u.add_role(:admin)
u.save!

# Project
project_scratch = create_project(name:"Scratch", description: "Default project to start with ")

# Study
study_test = create_study(project_id:project_scratch.id,
                          attachment_attributes: {category: 'Notebook',
                                                  data: File.new(File.expand_path("../notebook_seed.ipynb", __FILE__))})

# MDA
mda_test = create_mda(name:"MDA_Example", 
                      disciplines_attributes: [{
                                                 name: 'Disc1',
                                                 variables_attributes: [{name:"x1", io_mode:"in"},
                                                                        {name:"x2", io_mode:"in"},
                                                                        {name:"y2", io_mode:"in"},
                                                                        {name:"y1", io_mode:"out"}
                                                                        ],
                                                 
                                               },
                                               {name: 'Disc2',
                                                 variables_attributes: [{name:"y1", io_mode:"in"},
                                                                        {name:"x3", io_mode:"in"},
                                                                        {name:"y2", io_mode:"out"},
                                                                       ]
                                               },
                                               {name: 'Disc3',
                                                 variables_attributes: [{name:"y1", io_mode:"in"},
                                                                        {name:"y2", io_mode:"in"},
                                                                        {name:"z", io_mode:"out"}]
                                               }
                                              ])

# Onera 
u = create_user(login: "rlafage",
                email: "test@onera.fr")
u.add_role(:manager, project_scratch)
u.save!
