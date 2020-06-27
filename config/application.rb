require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WhatsOpt
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    Rails.autoloaders.main.ignore("#{Rails.root}/app/lib/whats_opt/services")
    Rails.autoloaders.main.ignore("#{Rails.root}/app/lib/whats_opt/string.rb")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.active_job.queue_adapter = :sucker_punch

    config.autoload_paths << "#{config.root}/app/lib/whats_opt/services"

    # Require `belongs_to` associations by default. Previous versions < rails 6 had false.
    config.active_record.belongs_to_required_by_default = false
  end
end
