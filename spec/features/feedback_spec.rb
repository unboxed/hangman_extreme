require 'spec_helper'

shared_examples "a feedbacker" do

  it "must allow to send support feedback" do
    VCR.use_cassette('support_feedback',
                     :record => :once,
                     :erb => true,
                     :match_requests_on => [:method,:uri]) do
      visit_home
      click_link('feedback')
      click_link('support')
      fill_in 'feedback_full_message', with: "I have a support issue for you"
      click_button 'send'
      page.should have_css("div.alert-info")
    end
  end

  it "must allow to send suggestion feedback" do
    VCR.use_cassette('suggestion_feedback',
                     :record => :once,
                     :erb => true,
                     :match_requests_on => [:method,:uri]) do
      visit_home
      click_link('feedback')
      click_link('suggestion')
      fill_in 'feedback_full_message', with: "I have a suggestion issue for you"
      click_button 'send'
      page.should have_css("div.alert-info")
    end
  end

end

describe 'explain', :redis => true do

  context "as mxit user", :google_analytics_vcr => true  do

    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
      stub_mxit_oauth
    end

    it_behaves_like "a feedbacker"

  end

  context "as mobile user", :smaato_vcr => true, :js => true do

    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it_behaves_like "a feedbacker"

  end

  context "as guest user", :smaato_vcr => true, :js => true do

    it "wont allow you to give feedback" do
      visit_home
      click_link('feedback')
      click_link('support')
      page.should have_css("div.alert")
    end

  end

end