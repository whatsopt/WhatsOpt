set :stage, :staging

set :deploy_to, "/var/www/html/rails/whatsopt"

set :rvm_ruby_version, "ruby-2.5.3@whatsopt"
set :server_name, "#{ENV['WHATSOPT_STAGING_SERVER']}"
server "#{ENV['WHATSOPT_STAGING_SERVER']}", user: "#{ENV['WHATSOPT_DEPLOY_USER']}", roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, "#{ENV['WHATSOPT_DEPLOY_USER']}@#{ENV['WHATSOPT_STAGING_SERVER']}"
role :web, "#{ENV['WHATSOPT_DEPLOY_USER']}@#{ENV['WHATSOPT_STAGING_SERVER']}"
role :db,  "#{ENV['WHATSOPT_DEPLOY_USER']}@#{ENV['WHATSOPT_STAGING_SERVER']}"
