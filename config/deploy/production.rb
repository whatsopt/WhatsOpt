set :stage, :production

if ENV['WHATSOPT_INTERNET']
  set :version, ENV["branch"] || "master"
  set :appname, "whatsopt-#{fetch(:version)}"
  set :dlvdir, "~/DELIVERY"
  set :repository, "#{ENV['WHATSOPT_INTERNET_DELIVERY_DIR']}/#{fetch(:appname)}"
  set :server, ENV['WHATSOPT_INTERNET_SERVER']
else
  set :server, ENV['WHATSOPT_INTRANET_SERVER']
end

set :deploy_to, "#{ENV['WHATSOPT_DEPLOY_DIR']}"
set :rvm_ruby_version, "ruby-2.7.2@whatsopt"
server fetch(:server), user: "#{ENV['WHATSOPT_DEPLOY_USER']}", roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"
role :web, "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"
role :db,  "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"
