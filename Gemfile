# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0"
# Use Puma as the app server
gem "puma", "~> 5.0"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem "webpacker", "~> 5.0"
gem 'shakapacker', "~>6.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"

# rEDuces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Protect from rogue client
gem "rack-attack"

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Unicorn as the app server
# gem 'unicorn'

# Use sqlite3 as the database for Active Record
gem "sqlite3"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "guard"
  gem "guard-minitest"
  # Adds support for Capybara system testing and selenium driver
  gem "capybara"
  gem "selenium-webdriver"
  # Compute test coverage
  gem 'simplecov',      require: false
  gem 'simplecov-lcov', require: false
  # rswag
  gem "rspec-rails"
  gem "rswag-specs", git: 'https://github.com/rswag/rswag.git', glob: 'rswag-specs/rswag-specs.gemspec'
end

group :development do
  # Use Capistrano for deployment
  gem "capistrano", "~> 3.11", require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem "capistrano-rvm"
  gem "capistrano-passenger"
  gem "capistrano-git-with-submodules", "~> 2.0"
  gem "capistrano-maintenance", "~> 1.2", require: false
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "rubocop", require: false
  gem "rubocop-rails_config"
  gem "solargraph"
end

group :staging, :production do
  gem "concurrent-ruby"
  gem "mysql2", "~>0.5"
  # gem 'redis'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"  # , platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# required in dev but seems to be required also in production
gem "highline"

# Use jquery as the JavaScript library
gem "jquery-rails"
gem "jquery-ui-rails"

# Authentication/Authorization
gem "devise", ">=4.7.1"
gem "devise_ldap_authenticatable"
gem "rolify"
gem "pundit"

# support CORS
gem "rack-cors", ">=1.0.5"

# Analysis as a tree
gem "ancestry"

# Disciplines as a list
gem "acts_as_list"

# JSON serializers
gem "active_model_serializers", "~> 0.10.12"

# Background jobs
gem "sucker_punch"

# Zip
gem "rubyzip", "~>2.3.0"

# UI
gem "popper" # bootstrap dependency
gem "bootstrap", "~> 4.0"
gem "font_awesome5_rails"
gem "data-confirm-modal"
gem 'tether-rails'

# thrift
gem "thrift", "~>0.15.0"

# Actiontext image processing
gem "image_processing", "~> 1.2"

# Document API
gem "rswag-api", git: 'https://github.com/rswag/rswag.git', glob: 'rswag-api/rswag-api.gemspec'

# To cache XDSM json to get XDSM standalone html
gem "deepsort"

# Add sprockets with Rails 7
gem "sprockets-rails"

# Fix io-wait 0.2.0 to deploy in production 
# (2.0.1 does not work in /var/log/httpd/error_log: You have already activated io-wait 0.2.0, but your Gemfile 
# requires io-wait 0.2.1. Since io-wait is a default gem, you can either remove your dependency 
# on it or try updating to a newer version of bundler that supports
# io-wait as a default gem.)
gem "io-wait", "0.2.0"
