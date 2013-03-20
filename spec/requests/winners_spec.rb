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

  it "must show the daily winners" do
    users = create_list(:user,5, :daily_precision => 100, :daily_streak => 100, :daily_rating => 100)
    random_users = create_list(:user,5, :daily_wins => 10)
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
    click_link('streak')
    users.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('random')
    random_users.each do |winner|
      page.should have_content(winner.name)
    end

  end

  it "must show the weekly winners" do
    users = create_list(:user,5, :weekly_precision => 100, :weekly_streak => 100, :weekly_rating => 100)
    random_users = create_list(:user,5, :weekly_wins => 35)
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
    click_link('streak')
    users.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('random')
    random_users.each do |winner|
      page.should have_content(winner.name)
    end
  end

  it "must show the winners if user mxit input is winner" do
    add_headers('X_MXIT_USER_INPUT' => 'winners')
    visit '/'
    page.current_path.should == winners_path
  end

end