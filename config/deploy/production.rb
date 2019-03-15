set :stage, :production

if ENV['WHATSOPT_INTERNET']
  set :version, "master"
  set :appname, "whatsopt-#{fetch(:version)}"
  set :dlvdir, "~/DELIVERY"
  set :repository, "/home/rlafage/DELIVERY/#{fetch(:appname)}"
  set :server, "ether"
else
  set :server, "selene"
end

set :deploy_to, "/dtis-app/whatsopt"
set :rvm_ruby_version, "ruby-2.5.3@whatsopt"
server fetch(:server), user: 'rlafage', roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, "rlafage@#{fetch(:server)}"
role :web, "rlafage@#{fetch(:server)}"
role :db,  "rlafage@#{fetch(:server)}"
