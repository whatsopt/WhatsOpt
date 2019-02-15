set :stage, :internet

set :version, "master"
set :appname, "whatsopt-#{fetch(:version)}"
set :dlvdir, "~/DELIVERY"
set :repository, "/home/rlafage/DELIVERY/#{fetch(:appname)}"

set :deploy_to, "/dtis-app/whatsopt"

set :rvm_custom_path, '/dtis-app/rvm'
set :rvm_ruby_version, "ruby-2.5.3@whatsopt-production"

set :server_name, "ether"
server 'ether', user: 'rlafage', roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, %w{rlafage@ether}
role :web, %w{rlafage@ether}
role :db,  %w{rlafage@ether}
