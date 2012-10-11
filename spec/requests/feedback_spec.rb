require 'spec_helper'

describe 'feedback' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
    stub_mxit_oauth :avatar_id => "gman"
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

  it "must allow to send support feedback" do
    visit '/'
    click_link('feedback')
    click_link('support')
    fill_in 'feedback', with: "I have a support issue for you"
    click_button 'submit'
    page.current_path.should == '/'
    page.should have_content("Thank you")
  end

  it "must allow to send suggestion feedback" do
    visit '/'
    click_link('feedback')
    click_link('suggestion')
    fill_in 'feedback', with: "I have a suggestion issue for you"
    click_button 'submit'
    page.current_path.should == '/'
    page.should have_content("Thank you")
  end




end