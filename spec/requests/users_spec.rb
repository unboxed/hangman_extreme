require 'spec_helper'

describe 'users' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
  end

  it "must show users rating" do
    create(:won_game, user: @current_user)
    visit '/'
    click_link('view_rank')
    page.should have_content("Your Ranking")
    click_link('root_page')
    page.current_path.should == '/'
  end

  it "must the show the current top players" do
    users = create_list(:user,9).each{|user| create(:won_game, user: user) }
    visit '/'
    click_link('view_rank')
    click_link('daily_wins')
    users.each do |user|
      page.should have_content(user.name)
    end
    click_link('root_page')
    page.current_path.should == '/'
    click_link('view_rank')
    click_link('weekly_rating')
    users.each do |user|
      page.should have_content(user.name)
    end
    click_link('weekly_precision')
    users.each do |user|
      page.should have_content(user.name)
    end
    click_link('monthly_precision')
    users.each do |user|
      page.should have_content(user.name)
    end
  end

end