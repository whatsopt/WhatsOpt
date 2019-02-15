set :stage, :production

set :deploy_to, "/dtis-app/whatsopt"

set :rvm_ruby_version, "ruby-2.5.3@whatsopt-internet"
set :server_name, "selene"
server 'selene', user: 'rlafage', roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, %w{rlafage@selene}
role :web, %w{rlafage@selene}
role :db,  %w{rlafage@selene}
