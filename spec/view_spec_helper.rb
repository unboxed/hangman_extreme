require 'spec_helper'
require 'support/capybara_view_helper'

RSpec.configure do |config|
  config.include RSpec::ViewHelper, :type => :view

end
