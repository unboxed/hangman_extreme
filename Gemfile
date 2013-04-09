source 'https://rubygems.org'

gem 'rails', '~> 3.2.1'

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', :require => false
end
platforms :ruby do
  gem 'pg'
end
gem 'ohm'
gem 'ohm-contrib', :require => 'ohm/contrib'

platforms :jruby do
  gem 'jruby-openssl'
end
gem 'cancan'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'kaminari'
gem 'mxit_api', '>= 0.2.2.pre'
gem "savon"
gem 'draper'
gem 'puma', '2.0.0.b7'
gem "passenger", "~> 4.0.0.rc4"
gem 'whenever', :require => false

# third party
gem 'airbrake'
gem 'uservoice-ruby'
gem 'gabba' # google analytics
gem 'newrelic_rpm'
gem 'wordnik'
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
  gem 'capistrano', :require => false
  gem 'rvm-capistrano', :require => false
end

group :development, :test do
  gem 'timecop'
  gem 'annotate'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  platforms :jruby do
    gem 'jdbc-mysql'
    gem 'activerecord-jdbcmysql-adapter', :require => false
  end
  platforms :ruby do
    gem 'mysql2'
  end
  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter', :require => false
    gem 'activerecord-jdbcpostgresql-adapter', :require => false
  end
  platforms :ruby do
    gem 'sqlite3'
    gem 'pg'
  end
  gem 'poltergeist'
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
