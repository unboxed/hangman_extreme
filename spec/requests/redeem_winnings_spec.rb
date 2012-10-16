require 'spec_helper'

describe 'users' do

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
    page.should have_content("100")
    click_link('root_page')
    page.current_path.should == '/'
  end

  it "must show users redeem winnings link" do

  end

end