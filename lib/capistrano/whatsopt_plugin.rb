# frozen_string_literal: true

require "capistrano/scm/plugin"

module Capistrano
  class WhatsOptPlugin < ::Capistrano::SCM::Plugin
    def set_defaults
    end

    def define_tasks
      namespace :whatsopt do
        task :create_release do
          on roles(:app) do
            version = fetch(:version)
            appname = fetch(:appname)
            dlvdir = fetch(:dlvdir)
            system("cd ~/workspace/WhatsOpt; rake whatsopt:delivery:pack[#{version}]")
            system("scp #{dlvdir}/whatsopt-#{version}.tar.gz #{ENV['WHATSOPT_DEPLOY_USER']}@#{ENV['WHATSOPT_INTERNET_SERVER']}:#{ENV['WHATSOPT_INTERNET_DELIVERY_DIR']}")
            execute :mkdir, "-p", release_path
            execute :tar, "-xzpf", "#{dlvdir}/#{appname}.tar.gz", "-C", release_path
          end
        end

        task :set_current_revision do
          set :current_revision, fetch(:version)
        end
      end
    end

    def register_hooks
      after "deploy:new_release_path", "whatsopt:create_release"
      before "deploy:set_current_revision", "whatsopt:set_current_revision"
    end
  end
end
