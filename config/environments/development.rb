Tessle::Application.configure do
  require 'pusher'

  Pusher.app_id = ENV['PUSHER_APP_ID']
  Pusher.key = ENV['PUSHER_KEY']
  Pusher.secret = ENV['PUSHER_SECRET_ID']

  # Rails 4 Upgrade
  config.eager_load = false

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # config.whiny_nils = true # (Rails 4 upgrade)

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  # change to true to allow email to be sent during development
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: "smtpout.secureserver.net",
    port: 80,
    domain: ENV["TESSLE_DOMAIN"],
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: ENV["TESSLE_USERNAME"],
    password: ENV["TESSLE_PASSWORD"]
  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  
  # Only use best-standards-support built into browsers
  # config.action_dispatch.best_standards_support = :builtin # (Rails 4 upgrade)

  # Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict # (Rails 4 upgrade)

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5 # (Rails 4 upgrade)

  # Do not compress assets
  # config.assets.compress = false # (Rails 4 upgrade)

  # Expands the lines which load the assets
  config.assets.debug = true

  # Logs less information
  config.log_level = :debug

end
