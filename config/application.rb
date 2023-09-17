require_relative 'boot'

require 'dotenv/load'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BudgetTrackerApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*' # Update this with the allowed origin(s) if you have a specific domain you want to allow.
        resource '*',
                 headers: :any,
                 methods: %i[get post put patch delete options head],
                 expose: ['X-Session-Token']
      end
    end

    config.active_job.queue_adapter = :delayed_job

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
