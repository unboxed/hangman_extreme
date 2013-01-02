require 'spec_helper'

describe 'winners' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
    stub_mxit_oauth
    MxitApiWrapper.any_instance.stub(:send_message).and_return(true)
  end

  it "must show the daily and weekly winners" do
    users = create_list(:user,10).sort{|x,y| x.name <=> y.name }
    users.each_with_index do |user,i|
      create_list(:won_game,35 + i, user: user)  # need at least 35 wins for  precision
    end
    Winner.create_daily_winners
    visit '/'
    click_link('rank')
    click_link('winners')
    users.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('precision')
    users.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('score')
    users.each do |winner|
      page.should have_content(winner.name)
    end
    Winner.create_weekly_winners
    visit '/'
    click_link('rank')
    click_link('winners')
    click_link('weekly')
    users.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('precision')
    users.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('score')
    users.each do |winner|
      page.should have_content(winner.name)
    end
  end

  it "must show the winners if user mxit input is winner" do
    add_headers('X_MXIT_USER_INPUT' => 'winners')
    visit '/'
    page.current_path.should == winners_path
  end

end