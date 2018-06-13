lock '3.11.0'

set :application, 'WhatsOpt' # config valid only for current version of Capistrano
#set :deploy_user, 'rlafage'

set :repo_url, 'ssh://designlab@endymion/iesta-base/designlab/gitrepos/WhatsOpt.git'

#set :git_strategy, Capistrano::SCM::Git::WithSubmodules
set :branch, :master
set :keep_releases, 5


set :log_level, :info

# set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{node_modules log tmp upload vendor/bundle public/system}

# fix ssh twice prompt with sshkit 1.11
# cf. https://github.com/capistrano/capistrano/issues/1774
set :ssh_options, known_hosts: Net::SSH::KnownHosts

SSHKit.config.command_map[:rake]  = "bundle exec rake" 
SSHKit.config.command_map[:rails] = "bundle exec rails"


before "deploy:assets:precompile", "deploy:yarn_install"

namespace :deploy do
  desc 'Run rake yarn:install'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install")
      end
    end
  end
end