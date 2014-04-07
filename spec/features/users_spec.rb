require 'features_helper'

shared_examples 'a registered user' do
  it 'must show users rating' do
    create_list(:won_game, 10, user: @current_user)
    visit_home
    click_link('view_rank')
    page.should have_content('Entered')
    page.should have_content('5 more games')
    click_link('Home')
    page.current_path.should be == '/'
  end

  it 'must allow to show and hide the hangman', :user_accounts_vcr => true do
    Dictionary.clear
    Dictionary.add('example')
    visit_home
    click_link('Play')
    click_button 'start_game'
    within('.letters') do
      click_link 'z'
    end
    page.should have_content('.---------')
    click_link('Home')
    click_link('options')
    click_link('No')

    click_link('Play')
    page.should have_no_content('.---------')

    click_link('Home')
    click_link('options')
    click_link('Yes')

    click_link('Play')
    page.should have_content('.---------')
  end
end

shared_examples 'a user browser' do
  it 'must the show the current top players' do
    users = create_list(:user,4).each{|user| create(:won_game, user: user) }
    User.new_day_set_scores!
    visit_home
    click_link('leaderboard')
    ['daily'].product(['streak','rating']).map{|x,y| "#{x}_#{y}"}.each do |link|
      click_link(link)
      users.each do |user|
        page.should have_content(user.name)
      end
    end
    ['weekly'].product(['rating','streak']).map{|x,y| "#{x}_#{y}"}.each do |link|
      click_link(link)
      users.each do |user|
        page.should have_content(user.name)
      end
    end
  end
end

describe 'users', :redis => true do
  context 'as mxit user', :google_analytics_vcr => true do
    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
      stub_mxit_oauth :first_name => 'Grant', :last_name => 'Speelman', :mobile_number => '0821234567'
    end

    it_behaves_like 'a user browser'
    it_behaves_like 'a registered user'

    it 'must show the options if user mxit input is options' do
      add_headers('X_MXIT_USER_INPUT' => 'options')
      visit_home
      page.current_path.should be == options_users_path
    end
  end

  context 'as mobile user', :facebook => true, :smaato_vcr => true, :js => true do
    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it_behaves_like 'a user browser'
    it_behaves_like 'a registered user'
  end

  context 'as guest user', :smaato_vcr => true, :js => true do
    it_behaves_like 'a user browser'
  end
end
