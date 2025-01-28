require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

# require 'apartment/custom_console'

module MyApp
  class Application < Rails::Application
    config.load_defaults 7.0

    config.time_zone = 'Moscow'
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ru

    config.action_controller.allow_forgery_protection = false
    config.active_job.queue_adapter = :sidekiq
    config.eager_load_paths << Rails.root.join('app')
    config.eager_load_paths << Rails.root.join('lib')
    config.autoload_paths += %W[#{config.root}/services #{config.root}/app/services/drop #{config.root}/app/classes]
    config.action_view.sanitized_allowed_tags = ['noscript']
  end
end
