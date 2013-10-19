require File.expand_path('../boot', __FILE__)
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

module JobTest5
  class Application < Rails::Application
    config.time_zone = 'Pacific Time (US & Canada)'
    config.i18n.default_locale = :en
  end
end
