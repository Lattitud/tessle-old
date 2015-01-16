source 'https://rubygems.org/'
ruby '2.1.1'

gem 'rails', '4.0.3'
gem 'unicorn'
gem 'unicorn-rails'
# gem 'em-http-request'

gem 'rails4_upgrade'

# Rails 4 Compatibility Gems
gem 'protected_attributes'

# Heroku Add-ons
gem 'newrelic_rpm'
gem 'pusher'
gem 'memcachier'
gem 'dalli'

gem 'faker', '~> 1.2.0'
gem 'will_paginate', '~> 3.0.4'
gem 'bootstrap-will_paginate', '~> 0.0.10'

gem 'devise', '~> 3.2.3'

gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
# gem 'omniauth'

gem 'bootstrap-on-rails'
gem 'jquery-rails'
gem 'jquery-rails-google-cdn'

gem 'simple_form'

gem "thumbs_up", "~> 0.6.4"
gem 'acts-as-taggable-on', "~> 3.0.1"
gem 'unread', :git => 'git://github.com/dsun412/unread.git'

gem 'rmagick', '2.13.2'
# gem 'mini_magick'
gem 'carrierwave'
gem 'fog', "~> 1.20.0"
gem 'unf' # Was raising warnings/errors for fog
# gem 'carrierwave_direct'
gem 's3_direct_upload'
gem 'sidekiq'
gem 'slim', '>= 1.1.0'
gem 'sinatra', '>= 1.3.0', :require => nil

gem 'pg'
gem 'pg_search', "~> 0.7.0"
gem 'impressionist', '~> 1.5.1'

group :development, :test do
  gem 'rspec-rails', '~> 2.14.0'
end

group :development do
  gem 'annotate', '~> 2.6.1'
  gem 'thin', '~> 1.6.1'
end

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'therubyracer', :platforms => :ruby
# gem 'angularjs-rails'

#gem 'jquery-fileupload-rails'

group :test do
  gem 'capybara', '~> 2.2.1'
  gem 'factory_girl_rails', '~> 4.4.0'

  gem 'cucumber-rails', '~> 1.4.0', :require => false
  gem 'database_cleaner', '~> 1.2.0'
end

# gem 'rack-no-www', '0.0.2'
gem 'kaminari', '~> 0.15.1'

# Needed for Heroku logging
gem 'rails_12factor', group: :production