require 'spec_helper'

describe 'clues' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
    stub_mxit_oauth # stub mixt profile auth
  end

  it "must allow use to purchase clue points" do
    create(:won_game, user: @current_user)
    visit '/'
    click_link('profile')
    page.should have_content("2 clue points")
    click_link('buy_clue_points')
    click_link('buy_clue11')
    click_button('submit')
    click_link('profile')
    page.should have_content("13 clue points")
  end

  it "must allow use to cancel purchase of clue points" do
    create(:won_game, user: @current_user)
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