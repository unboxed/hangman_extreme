require 'spec_helper'

describe 'users', :shinka_vcr => true, :redis => true do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
  end

  it "must show users rating" do
    create_list(:won_game, 10, user: @current_user)
    visit '/'
    click_link('view_rank')
    page.should have_content("Your Ranking")
    page.should have_content("Entered")
    page.should have_content("25 more games")
    click_link('home')
    page.current_path.should == '/'
  end

  it "must the show the current top players" do
    users = create_list(:user,4).each{|user| create(:won_game, user: user) }
    User.new_day_set_scores!
    User.add_clue_point_to_active_players!
    visit '/'
    click_link('view_rank')
    click_link('daily_streak')
    users.each do |user|
      page.should have_content(user.name)
    end
    click_link('home')
    page.current_path.should == '/'
    click_link('view_rank')
    ['daily'].product(['rating','precision','streak']).map{|x,y| "#{x}_#{y}"}.each do |link|
      click_link(link)
      users.each do |user|
        page.should have_content(user.name)
      end
    end
    ['weekly'].product(['streak','rating','precision']).map{|x,y| "#{x}_#{y}"}.each do |link|
      click_link(link)
      users.each do |user|
        page.should have_content(user.name)
      end
    end
  end

  it "must have a fill in profile information" do
    stub_mxit_oauth :first_name => "Grant", :last_name => "Speelman", :mobile_number => "0821234567"
    visit '/'
    click_link('authorise')
    page.should have_content("Grant Speelman")
    page.should have_content("0821234567")
    click_link('edit_real_name')
    fill_in 'user_real_name', with: "Joe Barber"
    click_button 'submit'
    click_link('edit_mobile_number')
    fill_in 'user_mobile_number', with: "0821234561"
    click_button 'submit'
    page.should have_content("Joe Barber")
    page.should have_content("0821234561")
    click_link('home')
    page.current_path.should == '/'
  end

  it "must show the profile if user mxit input is profile" do
    add_headers('X_MXIT_USER_INPUT' => 'profile')
    visit '/'
    page.current_path.should == profile_users_path
  end

end