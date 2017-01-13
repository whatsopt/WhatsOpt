lock '3.6.1'

set :application, 'WhatsOpt'# config valid only for current version of Capistrano
#set :deploy_user, 'rlafage'

set :repo_url, 'ssh://designlab@endymion/iesta-base/designlab/gitrepos/WhatsOpt.git'
set :scm, :git
set :branch, :master
set :keep_releases, 5

set :deploy_to, "/var/www/html/rails/whatsopt"

set :log_level, :info

#set :linked_files, %w{config/database.yml}
#set :linked_dirs, %w{bin log tmp upload vendor/bundle public/system}

SSHKit.config.command_map[:rake]  = "bundle exec rake" 
SSHKit.config.command_map[:rails] = "bundle exec rails"


