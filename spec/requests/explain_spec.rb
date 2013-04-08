require 'spec_helper'

shared_examples "a knowledge seeker" do

  ['rating', 'precision', 'streak', 'random', 'payouts'].each do |seek|

    it "must allow to browse explain #{seek} section" do
      visit '/'
      click_link('rank')
      page.should have_content("Daily")
      page.should have_content("Weekly")
      click_link('scoring_categories')
      page.should have_content("categories")
      click_link(seek)
      page.should have_content(seek.capitalize)
      click_link('home')
    end

  end

end

describe 'explain', :redis => true do

  context "as mxit user", :shinka_vcr => true  do

    before :each do
      @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
      set_mxit_headers('m2604100') # set mxit user
    end

    it_behaves_like "a knowledge seeker"

  end

  context "as mobile user", :smaato_vcr => true, :js => true do

    before :each do
      @current_user = create(:user, uid: '1234567', provider: 'facebook')
    end

    it_behaves_like "a knowledge seeker"

  end

end