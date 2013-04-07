require 'spec_helper'

shared_examples "a user browser" do

  it "must show users rating" do
    create_list(:won_game, 10, user: @current_user)
    visit '/'
    click_link('view_rank')
    page.should have_content("Entered")
    page.should have_content("25 more games")
    click_link('home')
    page.current_path.should == '/'
  end

  it "must the show the current top players" do
    users = create_list(:user,4).each{|user| create(:won_game, user: user) }
    User.new_day_set_scores!
    visit '/'
    click_link('view_rank')
    click_link('leaderboard')
    ['daily'].product(['precision','rating','streak']).map{|x,y| "#{x}_#{y}"}.each do |link|
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

end

describe 'users', :redis => true do

  context "as mxit user", :shinka_vcr => true do

    before :each do
      @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
      add_headers('X_MXIT_USERID_R' => 'm2604100')
      set_mxit_headers # set mxit user
      stub_mxit_oauth :first_name => "Grant", :last_name => "Speelman", :mobile_number => "0821234567"
    end

    it_behaves_like "a user browser"

    it "must show the profile if user mxit input is profile" do
      add_headers('X_MXIT_USER_INPUT' => 'profile')
      visit '/'
      page.current_path.should == profile_users_path
    end

  end

  context "as mobile user", :smaato_vcr => true do

    before :each do
      @current_user = create(:user, uid: '1234567', provider: 'facebook', mobile_number: '0821234567', real_name: 'Grant Speelman')
    end

    it_behaves_like "a user browser"

  end

end