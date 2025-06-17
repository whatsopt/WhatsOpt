# frozen_string_literal: true

set :stage, :production

if ENV["WHATSOPT_INTERNET"]
  set :version, ENV["branch"] || "master"
  set :appname, "whatsopt-#{fetch(:version)}"
  set :dlvdir, "~/DELIVERY"
  set :repository, "#{ENV['WHATSOPT_INTERNET_DELIVERY_DIR']}/#{fetch(:appname)}"
  set :server, ENV["WHATSOPT_INTERNET_SERVER"]
elsif ENV["WHATSOPT_RESTRICT"]
  puts "*****************************************************"
  puts "*** You are deploying to a restricted server.     ***" 
  puts "*** Please ensure you have the right permissions. ***"
  puts "*****************************************************"
  puts "Press enter to continue or Ctrl+C to abort."
  STDIN.gets
  set :server, ENV["WHATSOPT_RESTRICT_SERVER"]
else
  set :server, ENV["WHATSOPT_INTRANET_SERVER"]
end

set :deploy_to, "#{ENV['WHATSOPT_DEPLOY_DIR']}"
set :rvm_ruby_version, "ruby-3.3.5@whatsopt"
server fetch(:server), user: "#{ENV['WHATSOPT_DEPLOY_USER']}", roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"
role :web, "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"
role :db,  "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"