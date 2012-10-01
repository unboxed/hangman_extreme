require 'spec_helper'

describe 'users' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    add_headers('X_MXIT_USERID_R' => 'm2604100')
  end

  it "must show users rating" do
    create(:won_game, user: @current_user).score
    visit '/'
    click_link('view_rank')
    page.should have_content("You Ranking")
    click_link('root_page')
    page.current_path.should == '/'
  end

  it "must the show the current top players" do
    users = create_list(:user,9).each{|user| create(:won_game, user: user) }
    visit '/'
    click_link('view_rank')
    click_link('daily_rating')
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
    click_link('monthly_rating')
    users.each do |user|
      page.should have_content(user.name)
    end
  end

end