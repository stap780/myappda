require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyApp
  class Application < Rails::Application
    config.load_defaults 7.0
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
     config.time_zone = 'Moscow'
     config.active_record.default_timezone = :local
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ru

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    config.action_controller.allow_forgery_protection = false
    # config.active_job.queue_adapter = :delayed_job
    config.active_job.queue_adapter = :sidekiq
    # config.autoload_paths += %W(#{config.root}/app #{config.root}/lib)
    # config.eager_load_paths += %W(#{config.root}/app #{config.root}/lib)
    config.eager_load_paths << Rails.root.join('app')
    config.eager_load_paths << Rails.root.join('lib')
    config.autoload_paths += %W(#{config.root}/services #{config.root}/app/services/drop #{config.root}/app/classes)

  end
end
