set :stage, :staging

set :rvm_ruby_version, "ruby-2.3.0@whatsopt"
set :server_name, "rdri206h"
server 'rdri206h', user: 'rlafage', roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, %w{rlafage@rdri206h}
role :web, %w{rlafage@rdri206h}
role :db,  %w{rlafage@rdri206h}
