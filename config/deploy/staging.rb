set :stage, :staging

set :repo_url, 'ssh://designlab@endymion/iesta-base/designlab/gitrepos/WhatsOpt.git'
set :branch, :master

set :deploy_to, "/var/www/html/rails/whatsopt"

set :rvm_ruby_version, "ruby-2.3.3@whatsopt-staging"
set :server_name, "rdri206h"
server 'rdri206h', user: 'rlafage', roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, %w{rlafage@rdri206h}
role :web, %w{rlafage@rdri206h}
role :db,  %w{rlafage@rdri206h}
