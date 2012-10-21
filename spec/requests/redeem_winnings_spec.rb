require 'spec_helper'

describe 'redeem winnings' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit', prize_points: 100)
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
    stub_mxit_oauth
  end

  it "must show users redeem winnings link" do
    create(:won_game, user: @current_user)
    visit '/'
    click_link('redeem')
    page.should have_content("Redeeming Winnings")
    page.should have_content("100 prize points")
    click_link('root_page')
    page.current_path.should == '/'
  end

  it "must allow to redeem prize points for clues" do
    @current_user.update_attributes(:prize_points => 57, :clue_points => 10)
    visit '/'
    click_link('redeem')
    page.should have_content("57 prize points")
    click_link('clue_points')
    page.should have_content("10 clue points")
    click_button('redeem')
    page.should have_content("47 prize points")
    click_link('root_page')
    click_link('buy_clue_points')
    page.should have_content("20 clue points")
  end

  it "must allow to redeem prize points for moola" do
    @current_user.update_attributes(:prize_points => 157)
    visit '/'
    click_link('redeem')
    page.should have_content("157 prize points")
    click_link('moola')
    page.should have_content("100 moola")
    click_button('redeem')
    page.should have_content("57 prize points")
  end

end