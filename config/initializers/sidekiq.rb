require 'sidekiq'

# Already called in Unicorn
Sidekiq.configure_client do |config|
  config.redis = { :size => 1, namespace: 'sidekiq' }
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'sidekiq', size: 2 }

  # Sets a custom pool connection size for Sidekiq server process
  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=50"
    ActiveRecord::Base.establish_connection
  end
end