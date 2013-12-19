require 'spec_helper'

require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'draper/test/rspec_integration'

require 'support/vcr_helper'
require 'support/requests_facebook_helper'
require 'support/requests_user_helpers'
require 'support/requests_mxit_api_helpers'
require 'support/requests_capybara_helper'

RSpec.configure do |config|
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, window_size: [320,480] )
  end
  Capybara.javascript_driver = :poltergeist
  Capybara.default_wait_time = 20


  config.around(:each, :facebook => true) do |example|
    using_facebook_omniauth(&example)
  end

  config.around(:each, :google_analytics_vcr => true) do |example|
    VCR.use_cassette('google_analytics',
                     :record => :once,
                     :erb => true,
                     :allow_playback_repeats => true,
                     :match_requests_on => [:method,:host]) do
      example.call
    end
  end

  config.around(:each, :smaato_vcr => true) do |example|
    VCR.use_cassette('smaato',
                     :record => :once,
                     :erb => true,
                     :allow_playback_repeats => true,
                     :match_requests_on => [:method,:host]) do
      example.call
    end
  end
end
