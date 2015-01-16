# config/unicorn.rb
# port = case Rails.env
#   when 'production' then 8080
#   when 'staging'    then 3001
#   else 3000
# end

# listen port

if ENV["RAILS_ENV"] == "development"
  worker_processes 1
  port = '3000'
  listen port
else
  # Each dyno has 3 worker processes, can scale out to (500(db pool connections)/3) dynos
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
end

timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end 

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  # Making database concurrent with unicorn
  # if defined?(ActiveRecord::Base)
  #   config = Rails.application.config.database_configuration[Rails.env] # This line gives errors
    
  #   # Checks to see if connections are hung or dead every X seconds only in Rails 4
  #   config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds

  #   # Set this to 1 or 2 for bad connections
  #   config['pool']              = ENV['DB_POOL'] || 5 # if new connection needed, maximum of 5 will be used
  #   ActiveRecord::Base.establish_connection(config)
  # end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  #Initialize sidekiq client
  Sidekiq.configure_client do |config|
    config.redis = { size: 1, namespace: 'sidekiq' }
  end
end