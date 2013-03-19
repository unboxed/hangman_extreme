require 'spec_helper'

describe 'explain' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
    stub_mxit_oauth :user_id => "m2604100"
                                 # stub out uservoice
    stub_request(:post, "https://#{ENV['UV_SUBDOMAIN_NAME']}.uservoice.com/api/v1/tickets.json").
      to_return(:status => 200, :body => "{}")
    stub_request(:get, "https://#{ENV['UV_SUBDOMAIN_NAME']}.uservoice.com/api/v1/forums.json").
      to_return(:status => 200, :body => "{\"forums\":[{\"id\":123}]}")
    stub_request(:post, "https://#{ENV['UV_SUBDOMAIN_NAME']}.uservoice.com/oauth/request_token").
      to_return(:status => 200, :body => "{}")
    stub_request(:post, "https://#{ENV['UV_SUBDOMAIN_NAME']}.uservoice.com/api/v1/users/login_as.json").
      to_return(:status => 200, :body => "{\"token\":{\"oauth_token\":123, \"oauth_token_secret\":123}}")
    stub_request(:post, "https://.uservoice.com/api/v1/forums/123/suggestions.json").
      to_return(:status => 200, :body => "{}")
  end

  it "must allow to browse explain section" do
    visit '/'
    click_link('rank')
    click_link('scoring')
    click_link('rating')
    click_link('scoring')
    click_link('precision')
    click_link('scoring')
    click_link('winning_streak')
    click_link('scoring')
    click_link('payouts')
    click_link('home')
  end

end