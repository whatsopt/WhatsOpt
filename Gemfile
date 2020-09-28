# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.1"
# Use Puma as the app server
gem "puma", "~> 4.1"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"
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
  gem "coveralls", require: false
  # rswag
  gem "rspec-rails"
  gem "rswag-specs"
end

group :development do
  # Use Capistrano for deployment
  gem "capistrano", "~> 3.10", require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem "capistrano-rvm"
  gem "capistrano-passenger"
  gem "capistrano-git-with-submodules", "~> 2.0"
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "rubocop", require: false
  gem "rubocop-rails_config"
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

source "https://rails-assets.org" do
  gem "rails-assets-tether", ">= 1.1.0"
end

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
gem "active_model_serializers", "~> 0.10.7"

# Background jobs
gem "sucker_punch"

# Zip
gem "rubyzip"

# UI
gem "popper" # bootstrap dependency
gem "bootstrap", "~> 4.0"
gem "font_awesome5_rails"
gem "data-confirm-modal"

# thrift
gem "thrift", "0.11.0"

# Actiontext image processing
gem "image_processing", "~> 1.2"

# Document API
gem "rswag-api"

gem "deepsort"
