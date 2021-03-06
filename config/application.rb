require File.expand_path('../boot', __FILE__)

require 'rails/all'
require File.join(File.dirname(__FILE__), "redis.rb")
require File.join(File.dirname(__FILE__), "../lib", "captcha.rb")

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ownbox
  class Application < Rails::Application
    VERSION = '1.0.0'

    attr_accessor :version

    config.autoload_paths += %W(#{config.root}/lib/)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = [:ru, :en]
    config.i18n.default_locale = :ru;

    Rails.application.routes.default_url_options[:host] = 'ownbox.local:3000'
    config.middleware.use Captcha::Middleware
  end
end
