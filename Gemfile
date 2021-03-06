source 'http://rubygems.org'
#ruby '2.0.0' if ENV['STACK'] == 'cedar'

gem 'rails', '~> 4.0.0'

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', '>= 1.3.0', require: false
end
platforms :ruby do
  gem 'pg'
end

gem 'ohm', '~> 1.3.2'
gem 'ohm-contrib', require: false
gem 'cancan', require: false
gem 'mxit_api', '~> 0.3.0', require: false
gem 'draper'
gem 'puma', require: false
gem 'whenever', require: false
gem 'her'

gem 'sidekiq', '~> 2.17', require: false
gem 'sinatra', '>= 1.3.0', require: false # for sidekiq
gem 'slim', require: false # for sidekiq

# third party
gem 'airbrake', '~> 3.1'
gem 'newrelic_rpm'
gem 'staccato', require: false # google analytics
gem 'wordnik', require: false

platforms :jruby do
  gem 'therubyrhino', require: false
end
platforms :ruby do
  gem 'libv8', '~> 3.11.8', require: false
  gem 'therubyracer', require: false
end

gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'capistrano', '~> 2.0', require: false
  gem 'rvm-capistrano', require: false
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri]
  gem 'quiet_assets'
  gem 'spring', :platforms=>[:mri]
  gem 'rubocop'
end

group :development, :test do
  gem 'timecop', require: false
  gem 'annotate', require: false
  gem 'rspec-rails', '~> 2.13.0'
  gem 'factory_girl_rails'
  platforms :mri do
    gem 'debugger'
  end
end

group :test do
  gem 'test_after_commit'
  gem 'capybara', '~> 2.0.0', require: false
  gem 'database_cleaner', '~> 1.2.0', require: false
  gem 'launchy', require: false, :platforms=>[:mri]
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'flog', require: false
#  gem 'spork-rails'
  gem 'webmock', require: false
  gem 'vcr', require: false
  gem 'coveralls', require: false
end
