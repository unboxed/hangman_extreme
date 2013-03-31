require 'spec_helper'

describe 'feedback', :shinka_vcr => true, :redis => true do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_mxit_oauth :user_id => "m2604100"
  end

  it "must allow to send support feedback" do
    VCR.use_cassette('support_feedback',
                     :record => :once,
                     :erb => true,
                     :match_requests_on => [:method,:query]) do
      visit '/'
      click_link('feedback')
      click_link('support')
      fill_in 'feedback', with: "I have a support issue for you"
      click_button 'submit'
      page.current_path.should == '/'
      page.should have_content("Thank you")
    end
  end

  it "must allow to send suggestion feedback" do
    VCR.use_cassette('suggestion_feedback',
                     :record => :once,
                     :erb => true,
                     :match_requests_on => [:method,:query]) do
      visit '/'
      click_link('feedback')
      click_link('suggestion')
      fill_in 'feedback', with: "I have a suggestion issue for you"
      click_button 'submit'
      page.current_path.should == '/'
      page.should have_content("Thank you")
    end
  end

end