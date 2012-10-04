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

  it "must have a fill in profile information" do
    body = %&{"FirstName":"Grant",
              "LastName":"Speelman",
              "MobileNumber":"0821234567"}&
    stub_request(:get, "https://auth.mxit.com/user/profile").to_return(:status => 200, :body => body, :headers => {})
    token_body = %&{ "access_token":"c71219af53f5409e9d1db61db8a08248" }&
    stub_request(:post, "https://auth.mxit.com/token").to_return(:status => 200, :body => token_body, :headers => {})
    visit '/'
    click_link('authorise')
    page.should have_content("Grant Speelman")
    page.should have_content("0821234567")
    click_link('edit')
    fill_in 'user_real_name', with: "Joe Barber"
    fill_in 'user_mobile_number', with: "0821234561"
    click_button 'submit'
    page.should have_content("Joe Barber")
    page.should have_content("0821234561")
    click_link('correct')
    page.current_path.should == '/'
  end

end