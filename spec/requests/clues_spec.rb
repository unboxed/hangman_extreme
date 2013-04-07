require 'spec_helper'

describe 'purchases', :redis => true do

  context "as mxit user", :shinka_vcr => true do

    before :each do
      @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
      set_mxit_headers('m2604100') # set mxit user
      stub_mxit_oauth # stub mixt profile auth
    end

    it "must allow user to purchase credits" do
      visit '/'
      click_link('profile')
      page.should have_content("2 credits")
      click_link('buy_credits')
      click_link('buy_credits11')
      click_link('submit')
      click_link('profile')
      page.should have_content("13 credits")
    end

    it "must allow user to cancel purchase of clue points" do
      visit '/'
      click_link('profile')
      page.should have_content("2 credits")
      click_link('buy_credits')
      click_link('buy_credits11')
      click_link('cancel')
      click_link('profile')
      page.should have_content("2 credits")
    end

  end

  context "as mobile user", :smaato_vcr => true, :js => true do

    before :each do
      @current_user = create(:user, uid: '1234567', provider: 'facebook')
    end

    it "must not allow user to purchase of clue points" do
      visit '/'
      click_link('profile')
      page.should have_content("2 credits")
      click_link('buy_clue_points')
      page.should have_content("Coming soon, credits purchases")
    end

  end

end