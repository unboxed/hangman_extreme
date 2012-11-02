require 'spec_helper'

describe 'winners' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
    stub_mxit_oauth
    MxitApi.any_instance.stub(:send_message).and_return(true)
  end

  it "must show the daily winners" do
    users = create_list(:user,10)
    users.each do |user|
      create_list(:won_game,rand(5) + 1, user: user)
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
    click_link('points')
    users.each do |winner|
      page.should have_content(winner.name)
    end
  end

  it "must show the weekly winners" do
    users = create_list(:user,10)
    users.each do |user|
      create_list(:won_game,rand(5) + 1, user: user)
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
    click_link('points')
    users.each do |winner|
      page.should have_content(winner.name)
    end
  end

end