require 'spec_helper'

shared_examples "a knowledge seeker" do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
  end

  it "must allow to browse explain section" do
    visit '/'
    click_link('rank')
    page.should have_content("Your Ranking")
    click_link('scoring_categories')
    page.should have_content("Explaination")
    click_link('rating')
    page.should have_content("Rating Category")
    click_link('scoring_categories')
    page.should have_content("Explaination")
    click_link('precision')
    page.should have_content("Precision Category")
    click_link('scoring_categories')
    page.should have_content("Explaination")
    click_link('winning_streak')
    page.should have_content("Streak Category")
    click_link('scoring')
    click_link('winning_random')
    click_link('scoring')
    page.should have_content("Explaination")
    click_link('payouts')
    page.should have_content("Daily Payouts")
    click_link('home')
  end

end

describe 'explain', :shinka_vcr => true, :redis => true do

  context "as mxit user" do

    before :each do
      @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
      set_mxit_headers('m2604100') # set mxit user
      stub_shinka_request # stub shinka request
      stub_google_tracking # stub google tracking
    end

    it_behaves_like "a knowledge seeker"

  end

  context "as mobile user", :js => true do

    before :each do
      @current_user = create(:user, uid: '1234567', provider: 'facebook')
      stub_google_tracking # stub google tracking
    end

    it_behaves_like "a knowledge seeker"

  end

end