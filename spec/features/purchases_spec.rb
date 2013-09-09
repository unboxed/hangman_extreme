require 'features_helper'

describe 'purchases', :redis => true do

  context "as mxit user", :google_analytics_vcr => true do

    before :each do
      @current_user = mxit_user('m2604100')
      @credits = @current_user.credits
      set_mxit_headers('m2604100') # set mxit user
      stub_mxit_oauth # stub mixt profile auth
    end

    it "must allow user to purchase credits" do
      visit_home
      click_link('profile')
      page.should have_content("#{@credits} credits")
      click_link('buy_credits')
      click_link('buy_credits11')
      click_link('submit')
      click_link('profile')
      page.should have_content("#{@credits + 11} credits")
    end

    it "must allow user to cancel purchase of clue points" do
      visit_home
      click_link('profile')
      page.should have_content("#{@credits} credits")
      click_link('buy_credits')
      click_link('buy_credits11')
      click_link('cancel')
      click_link('profile')
      page.should have_content("#{@credits} credits")
    end

  end

  context "as mobile user", :facebook => true, :smaato_vcr => true, :js => true do

    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it "must not allow user to purchase of clue points" do
      visit_home
      click_link('buy_credits')
      page.should have_content("Coming soon, credits purchases")
    end

  end

  context "as guest user", :smaato_vcr => true, :js => true do

    it "must not allow user to purchase of clue points" do
      visit_home
      click_link('buy_credits')
      page.should have_content("Coming soon, credits purchases")
    end

  end

end
