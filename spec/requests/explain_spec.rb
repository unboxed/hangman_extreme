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
    click_link('scoring')
    click_link('rating')
    click_link('scoring')
    click_link('precision')
    click_link('scoring')
    click_link('winning_streak')
    click_link('scoring')
    click_link('winning_random')
    click_link('scoring')
    click_link('payouts')
    click_link('home')
  end

end

describe 'explain', :shinka_vcr => true, :redis => true do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
  end

  context "as mxit user" do

    it_behaves_like "a knowledge seeker"

  end


end