require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WhatsOpt
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    Rails.autoloaders.main.ignore("#{Rails.root}/lib")
    Rails.autoloaders.main.ignore("#{Rails.root}/app/lib/whats_opt/services")
    Rails.autoloaders.main.ignore("#{Rails.root}/app/lib/whats_opt/string.rb")
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_job.queue_adapter = :sucker_punch

    # Thrift generated code needs this
    config.autoload_paths << "#{config.root}/app/lib/whats_opt/services"

    # Keep previous defaults
    # See https://guides.rubyonrails.org/configuring.html

    # Require `belongs_to` associations by default. Rails >= 5.0 default is true.
    config.active_record.belongs_to_required_by_default = false

    # Add autoload_path to load path. Rails >= 7.1 default is false.
    config.add_autoload_paths_to_load_path = true

    # Add autoload_path to load path. Rails >= 7.1 default is nil.
    config.active_record.default_column_serializer = YAML
  end
end
