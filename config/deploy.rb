lock '~>3.16.0'

set :application, 'WhatsOpt' # config valid only for current version of Capistrano

set :repo_url, "#{ENV['WHATSOPT_REPOSITORY']}"

set :branch, ENV['branch'] || :master
set :keep_releases, 5
 
set :log_level, :info

# set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{node_modules log tmp upload vendor/bundle public/system}
set :linked_files, %w{config/master.key config/configuration.yml config/ldap.yml config/database.yml}

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
