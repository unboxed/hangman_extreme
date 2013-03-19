source 'https://rubygems.org'

gem 'rails', '~> 3.2.1'

# If running on JRuby, use the activerecord-jdbc-adapter
platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', :require => false
end
platforms :ruby do
  gem 'pg'
end
gem 'cancan'
gem 'omniauth'
gem 'kaminari'
gem 'nokogiri'
gem 'json'
gem 'airbrake'
gem 'redis-settings'
gem 'rest-client', require: 'rest_client'
gem 'redis'
gem 'ohm'
gem 'mxit_api', '>= 0.2.2.pre'
gem "savon"
platforms :jruby do
  gem "torquebox"
  # gem "jruby-openssl"
end

# third party
gem 'uservoice-ruby'
gem 'gabba' # google analytics
gem 'newrelic_rpm'
gem 'wordnik'
gem 'remote_syslog'
gem 'librato-metrics', :require => 'librato/metrics'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  platforms :jruby do
    gem 'therubyrhino'
  end
  platforms :ruby do
    gem 'libv8', '~> 3.11.8'
    gem 'therubyracer'
  end
#  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'capistrano'
  gem 'torquebox-capistrano-support'
end

group :development, :test do
  gem 'timecop'
  gem 'annotate'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'heroku'
end

group :test do
  platforms :jruby do
    gem 'jdbc-mysql'
    gem 'activerecord-jdbcmysql-adapter'
    gem 'jdbc-sqlite3', :require => false
  end
  platforms :ruby do
    gem 'mysql2'
    gem 'sqlite3'
  end
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'flog'
  gem "spork-rails"
  gem 'webmock'
  gem 'vcr'
end
