set :stage, :production

set :rvm_ruby_string, "ruby-2.3.0@whatsopt"
set :server_name, "rdri206h"
server 'rdri206h', user: 'rlafage', roles: %w{app web db}, primary: true

role :app, %w{rlafage@rdri206h}
role :web, %w{rlafage@rdri206h}
role :db,  %w{rlafage@rdri206h}

