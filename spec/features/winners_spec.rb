require 'features_helper'
require 'timecop'

shared_examples "a winner viewer" do

  it "must show the daily and weekly winners" do
    users = create_list(:user,5, :daily_streak => 100, :daily_rating => 100, :daily_wins => Winner.daily_random_games_required)
    random_users = create_list(:user,5, :daily_wins => Winner.daily_random_games_required)
    Timecop.freeze(Date.yesterday) do
      Jobs::CreateDailyWinners.execute
    end
    visit_home
    click_link('winners')
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
    users = create_list(:user,5, weekly_streak: 100, weekly_rating: 100, weekly_wins: 100)
    random_users = create_list(:user,5, :weekly_wins => Winner.weekly_random_games_required)
    Timecop.freeze(Date.current.beginning_of_week.yesterday) do
      Jobs::CreateWeeklyWinners.execute
    end
    visit_home
    click_link('winners')
    click_link('weekly')
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

end

describe 'winners',  :redis => true do

  before :each do
    stub_mxit_oauth
  end

  context "as mxit user", :google_analytics_vcr => true do

    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
      MxitApiWrapper.any_instance.stub(:send_message).and_return(true)
    end

    it "must show the winners if user mxit input is winner" do
      add_headers('X_MXIT_USER_INPUT' => 'winners')
      visit_home
      page.current_path.should == winners_path
    end

    it_behaves_like "a winner viewer"

  end

  context "as mobile user", :facebook => true, :smaato_vcr => true, :js => true do

    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it_behaves_like "a winner viewer"

  end

  context "as guest user", :smaato_vcr => true, :js => true do

    it_behaves_like "a winner viewer"

  end


end
