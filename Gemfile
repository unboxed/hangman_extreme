source 'http://rubygems.org'

gem 'rails', '~> 4.0.0'

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', '>= 1.3.0', require: false
end
platforms :ruby do
  gem 'pg'
end
gem 'ohm'
gem 'ohm-contrib', require: 'ohm/contrib'
gem 'cancan'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'kaminari'
gem 'mxit_api', '>= 0.2.2.pre'
gem "savon"
gem 'draper'
gem 'puma'
gem 'whenever', require: false

gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', require: false # for sidekiq
gem 'slim', require: false # for sidekiq

#gem 'backup', :require => false
#gem 'httparty', :require => false # for backup
#gem 'dropbox-sdk', :require => false  # for backup

# third party
gem 'airbrake'
gem 'uservoice-ruby'
gem 'gabba' # google analytics
gem 'newrelic_rpm'
gem 'wordnik'
gem 'librato-metrics', require: 'librato/metrics'

#group :assets do
  platforms :jruby do
    gem 'therubyrhino'
  end
  platforms :ruby do
    gem 'libv8', '~> 3.11.8'
    gem 'therubyracer'
  end
  gem 'wiselinks'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'jquery-rails'
#end

group :development do
  gem 'capistrano', require: false
  gem 'rvm-capistrano', require: false
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :rbx]
  gem 'quiet_assets'
end

group :development, :test do
  gem 'timecop'
  gem 'annotate'
  gem 'rspec-rails', '~> 2.13.0'
  gem 'factory_girl_rails'
end

group :test do
  platforms :jruby do
    gem 'jdbc-mysql'
    gem 'activerecord-jdbcmysql-adapter', '>= 1.3.0', require: false
    gem 'activerecord-jdbcsqlite3-adapter', '>= 1.3.0', require: false
    gem 'activerecord-jdbcpostgresql-adapter', '>= 1.3.0', require: false
  end
  platforms :ruby do
    gem 'mysql2'
    gem 'sqlite3'
    gem 'pg'
  end
  gem 'test_after_commit'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'capybara', '~> 2.0.0'
  gem 'database_cleaner', "~> 1.1.1", :git => 'https://github.com/tommeier/database_cleaner', ref: 'b0c666e'
  gem 'launchy'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'flog'
#  gem 'spork-rails'
  gem 'webmock'
  gem 'vcr'
  gem 'coveralls', require: false
end
