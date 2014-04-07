require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'
ENV['DB_CLEANER_STRATEGY'] ||= 'transaction'
ENV['UV_SUBDOMAIN_NAME'] ||= 'uv'
ENV['UV_API_KEY'] ||= '1'
ENV['UV_API_SECRET'] ||= '1'
ENV['MXIT_CLIENT_ID'] ||= '1'
ENV['SHINKA_AUID'] ||= '1'
ENV['GA_TRACKING_CODE'] ||= 'UA-00000000-3'
ENV['MXIT_VENDOR_ID'] ||= '1'
ENV['USER_ACCOUNT_API'] ||= 'http://user.example.com/api'
ENV['SESSION_TOKEN'] ||= ('a' * 31)

if (ENV['COVERAGE'] == 'on')
  require 'simplecov'
  require 'simplecov-rcov'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start 'rails' do
    add_filter '/vendor/'
  end
end

if ENV['COVERALLS']
  require 'coveralls'
  Coveralls.wear!('rails')
end

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'webmock/rspec'
require 'database_cleaner'


WebMock.disable_net_connect!(:allow_localhost => true)
def in_memory_database?
  Rails.configuration.database_configuration[ENV['RAILS_ENV']]['database'] == ':memory:'
end

if in_memory_database?
  load "#{Rails.root}/db/schema.rb"
  ActiveRecord::Migrator.up('db/migrate') # then run migrations
end
FactoryGirl.reload
DatabaseCleaner.clean_with :truncation


#Capybara.server do |app, port|
#  Puma::Server.new(app).tap do |s|
#    s.add_tcp_listener '127.0.0.1', port
#  end.run.join
#end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.filter_run_excluding :inconsistent => true if ENV['EXCLUDE_INCONSISTENT']


  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
  config.before(:suite) do
    DatabaseCleaner.strategy = ENV['DB_CLEANER_STRATEGY'].to_sym
  end

  config.before(:all, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:all, :js => true) do
    DatabaseCleaner.strategy = ENV['DB_CLEANER_STRATEGY'].to_sym
  end

  config.before(:each) do
    DatabaseCleaner.start
    Rails.cache.clear
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Timecop.return if defined?(Timecop)
  end

  config.before(:each, :redis => true) do
    Ohm.flush
  end
end
