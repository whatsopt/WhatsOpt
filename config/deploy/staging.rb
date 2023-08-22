# frozen_string_literal: true

set :stage, :staging

set :server, ENV["WHATSOPT_STAGING_SERVER"]

set :deploy_to, "#{ENV['WHATSOPT_DEPLOY_DIR']}"
set :rvm_ruby_version, "ruby-3.0.3@whatsopt"
server fetch(:server), user: "#{ENV['WHATSOPT_DEPLOY_USER']}", roles: %w{app web db}, primary: true

set :passenger_restart_with_touch, true

role :app, "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"
role :web, "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"
role :db,  "#{ENV['WHATSOPT_DEPLOY_USER']}@#{fetch(:server)}"
