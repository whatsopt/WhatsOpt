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
    p.tree_json = params[:tree_json]
    p.conns_json = params[:conns_json]
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
project_test = create_project(name:"Scratch", description: "Default project to start with ")

# Study
study_test = create_study(name:"Study Example", project_id:project_test.id,
                          tree_json: JSON.parse('{"subsystem_type": "group", "type": "root", "name": "root", "children": [{"subsystem_type": "component", "type": "subsystem", "name": "D_ini", "children": [{"dtype": "float", "type": "unknown", "name": "D", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "x_str_ini", "children": [{"dtype": "ndarray", "type": "unknown", "name": "x_str", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "WE_ini", "children": [{"dtype": "float", "type": "unknown", "name": "WE", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "x_pro_ini", "children": [{"dtype": "float", "type": "unknown", "name": "x_pro", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "z_ini", "children": [{"dtype": "ndarray", "type": "unknown", "name": "z", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "ESF_ini", "children": [{"dtype": "float", "type": "unknown", "name": "ESF", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_ESF", "children": [{"dtype": "float", "type": "unknown", "name": "con_esf", "implicit": false}, {"dtype": "float", "type": "param", "name": "ESF"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "x_aer_ini", "children": [{"dtype": "float", "type": "unknown", "name": "x_aer", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "L_ini", "children": [{"dtype": "float", "type": "unknown", "name": "L", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "Struc", "children": [{"dtype": "float", "type": "unknown", "name": "WT", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "Theta", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "WF", "implicit": false}, {"dtype": "ndarray", "type": "unknown", "name": "sigma", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "z"}, {"dtype": "ndarray", "type": "param", "name": "x_str"}, {"dtype": "float", "type": "param", "name": "L"}, {"dtype": "float", "type": "param", "name": "WE"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "WT_ini", "children": [{"dtype": "float", "type": "unknown", "name": "WT", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Str_Aer_WT", "children": [{"dtype": "float", "type": "unknown", "name": "con_str_aer_wt", "implicit": false}, {"dtype": "float", "type": "param", "name": "WT"}, {"dtype": "float", "type": "param", "name": "WTi"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "Propu", "children": [{"dtype": "float", "type": "unknown", "name": "SFC", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "WE", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "ESF", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "DT", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "Temp", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "z"}, {"dtype": "float", "type": "param", "name": "x_pro"}, {"dtype": "float", "type": "param", "name": "D"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Pro_Aer_ESF", "children": [{"dtype": "float", "type": "unknown", "name": "con_pro_aer_esf", "implicit": false}, {"dtype": "float", "type": "param", "name": "ESF"}, {"dtype": "float", "type": "param", "name": "ESFi"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_DT", "children": [{"dtype": "float", "type": "unknown", "name": "con_dt", "implicit": false}, {"dtype": "float", "type": "param", "name": "DT"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Temp", "children": [{"dtype": "float", "type": "unknown", "name": "con_temp", "implicit": false}, {"dtype": "float", "type": "param", "name": "Temp"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Pro_Str_WE", "children": [{"dtype": "float", "type": "unknown", "name": "con_pro_str_we", "implicit": false}, {"dtype": "float", "type": "param", "name": "WE"}, {"dtype": "float", "type": "param", "name": "WEi"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Sigma5", "children": [{"dtype": "float", "type": "unknown", "name": "con_sigma5", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "sigma"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Sigma4", "children": [{"dtype": "float", "type": "unknown", "name": "con_sigma4", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "sigma"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Sigma1", "children": [{"dtype": "float", "type": "unknown", "name": "con_sigma1", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "sigma"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "Theta_ini", "children": [{"dtype": "float", "type": "unknown", "name": "Theta", "implicit": false}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Theta_sup", "children": [{"dtype": "float", "type": "unknown", "name": "con_Theta_up", "implicit": false}, {"dtype": "float", "type": "param", "name": "Theta"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "Aero", "children": [{"dtype": "float", "type": "unknown", "name": "L", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "D", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "fin", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "dpdx", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "z"}, {"dtype": "float", "type": "param", "name": "x_aer"}, {"dtype": "float", "type": "param", "name": "WT"}, {"dtype": "float", "type": "param", "name": "Theta"}, {"dtype": "float", "type": "param", "name": "ESF"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "Perfo", "children": [{"dtype": "float", "type": "unknown", "name": "R", "implicit": false}, {"dtype": "float", "type": "unknown", "name": "Rm", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "z"}, {"dtype": "float", "type": "param", "name": "WT"}, {"dtype": "float", "type": "param", "name": "WF"}, {"dtype": "float", "type": "param", "name": "fin"}, {"dtype": "float", "type": "param", "name": "SFC"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "Obj", "children": [{"dtype": "float", "type": "unknown", "name": "obj", "implicit": false}, {"dtype": "float", "type": "param", "name": "Rm"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Dpdx", "children": [{"dtype": "float", "type": "unknown", "name": "con_dpdx", "implicit": false}, {"dtype": "float", "type": "param", "name": "dpdx"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Aer_Pro_D", "children": [{"dtype": "float", "type": "unknown", "name": "con_aer_pro_d", "implicit": false}, {"dtype": "float", "type": "param", "name": "D"}, {"dtype": "float", "type": "param", "name": "Di"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Aer_Str_L", "children": [{"dtype": "float", "type": "unknown", "name": "con_aer_str_l", "implicit": false}, {"dtype": "float", "type": "param", "name": "L"}, {"dtype": "float", "type": "param", "name": "Li"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Theta_inf", "children": [{"dtype": "float", "type": "unknown", "name": "con_Theta_low", "implicit": false}, {"dtype": "float", "type": "param", "name": "Theta"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Str_Aer_Theta", "children": [{"dtype": "float", "type": "unknown", "name": "con_str_aer_theta", "implicit": false}, {"dtype": "float", "type": "param", "name": "Theta"}, {"dtype": "float", "type": "param", "name": "Thetai"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Sigma3", "children": [{"dtype": "float", "type": "unknown", "name": "con_sigma3", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "sigma"}]}, {"subsystem_type": "component", "type": "subsystem", "name": "con_Sigma2", "children": [{"dtype": "float", "type": "unknown", "name": "con_sigma2", "implicit": false}, {"dtype": "ndarray", "type": "param", "name": "sigma"}]}]}'),
                          conns_json: JSON.parse('[{"src": "ESF_ini.ESF", "tgt": "Aero.ESF"}, {"src": "Theta_ini.Theta", "tgt": "Aero.Theta"}, {"src": "WT_ini.WT", "tgt": "Aero.WT"}, {"src": "x_aer_ini.x_aer", "tgt": "Aero.x_aer"}, {"src": "z_ini.z", "tgt": "Aero.z"}, {"src": "Perfo.Rm", "tgt": "Obj.Rm"}, {"src": "Propu.SFC", "tgt": "Perfo.SFC"}, {"src": "Struc.WF", "tgt": "Perfo.WF"}, {"src": "Struc.WT", "tgt": "Perfo.WT"}, {"src": "Aero.fin", "tgt": "Perfo.fin"}, {"src": "z_ini.z", "tgt": "Perfo.z"}, {"src": "D_ini.D", "tgt": "Propu.D"}, {"src": "x_pro_ini.x_pro", "tgt": "Propu.x_pro"}, {"src": "z_ini.z", "tgt": "Propu.z"}, {"src": "L_ini.L", "tgt": "Struc.L"}, {"src": "WE_ini.WE", "tgt": "Struc.WE"}, {"src": "x_str_ini.x_str", "tgt": "Struc.x_str"}, {"src": "z_ini.z", "tgt": "Struc.z"}, {"src": "Aero.D", "tgt": "con_Aer_Pro_D.D"}, {"src": "D_ini.D", "tgt": "con_Aer_Pro_D.Di"}, {"src": "Aero.L", "tgt": "con_Aer_Str_L.L"}, {"src": "L_ini.L", "tgt": "con_Aer_Str_L.Li"}, {"src": "Propu.DT", "tgt": "con_DT.DT"}, {"src": "Aero.dpdx", "tgt": "con_Dpdx.dpdx"}, {"src": "ESF_ini.ESF", "tgt": "con_ESF.ESF"}, {"src": "Propu.ESF", "tgt": "con_Pro_Aer_ESF.ESF"}, {"src": "ESF_ini.ESF", "tgt": "con_Pro_Aer_ESF.ESFi"}, {"src": "Propu.WE", "tgt": "con_Pro_Str_WE.WE"}, {"src": "WE_ini.WE", "tgt": "con_Pro_Str_WE.WEi"}, {"src": "Struc.sigma", "tgt": "con_Sigma1.sigma"}, {"src": "Struc.sigma", "tgt": "con_Sigma2.sigma"}, {"src": "Struc.sigma", "tgt": "con_Sigma3.sigma"}, {"src": "Struc.sigma", "tgt": "con_Sigma4.sigma"}, {"src": "Struc.sigma", "tgt": "con_Sigma5.sigma"}, {"src": "Struc.Theta", "tgt": "con_Str_Aer_Theta.Theta"}, {"src": "Theta_ini.Theta", "tgt": "con_Str_Aer_Theta.Thetai"}, {"src": "Struc.WT", "tgt": "con_Str_Aer_WT.WT"}, {"src": "WT_ini.WT", "tgt": "con_Str_Aer_WT.WTi"}, {"src": "Propu.Temp", "tgt": "con_Temp.Temp"}, {"src": "Theta_ini.Theta", "tgt": "con_Theta_inf.Theta"}, {"src": "Theta_ini.Theta", "tgt": "con_Theta_sup.Theta"}]'))

# Project
run_test = create_run(name:"Run Test", study_id:study_test.id)

# Onera 
u = create_user(login: "rlafage",
                email: "test@onera.fr")
u.add_role(:manager, project_test)
u.save!
