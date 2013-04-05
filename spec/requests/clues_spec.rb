require 'spec_helper'

describe 'clues', :redis => true do

  context "as mxit user", :shinka_vcr => true do

    before :each do
      @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
      set_mxit_headers('m2604100') # set mxit user
      stub_mxit_oauth # stub mixt profile auth
    end

    it "must allow user to purchase clue points" do
      visit '/'
      click_link('profile')
      page.should have_content("2 clue points")
      click_link('buy_clue_points')
      click_link('buy_clue11')
      click_link('submit')
      click_link('profile')
      page.should have_content("13 clue points")
    end

    it "must allow user to cancel purchase of clue points" do
      visit '/'
      click_link('profile')
      page.should have_content("2 clue points")
      click_link('buy_clue_points')
      click_link('buy_clue11')
      click_link('cancel')
      click_link('profile')
      page.should have_content("2 clue points")
    end

  end

  context "as mobile user", :smaato_vcr => true, :js => true do

    before :each do
      @current_user = create(:user, uid: '1234567', provider: 'facebook')
    end

    it "must not allow user to purchase of clue points" do
      visit '/'
      click_link('profile')
      page.should have_content("2 clue points")
      click_link('buy_clue_points')
      page.should have_content("Coming soon, clue point purchases")
    end

  end

end