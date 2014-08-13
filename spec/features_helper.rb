require 'spec_helper'

require 'capybara/rails'
require 'capybara/rspec'
require 'draper/test/rspec_integration'

require 'support/vcr_helper'
require 'support/requests_user_helpers'
require 'support/requests_mxit_api_helpers'
require 'support/requests_capybara_helper'

RSpec.configure do |config|
  config.around(:each, :google_analytics_vcr => true) do |example|
    VCR.use_cassette('google_analytics',
                     :record => :once,
                     :erb => true,
                     :allow_playback_repeats => true,
                     :match_requests_on => [:method,:host]) do
      example.call
    end
  end

  config.around(:each, :user_accounts_vcr => true) do |example|
    VCR.use_cassette('user_accounts',
                     :record => :once,
                     :erb => true,
                     :allow_playback_repeats => true,
                     :match_requests_on => [:method,:host]) do
      example.call
    end
  end
end
