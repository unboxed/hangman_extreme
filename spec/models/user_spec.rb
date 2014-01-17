# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  name                  :text
#  uid                   :string(255)
#  provider              :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  weekly_rating         :integer          default(0)
#  yearly_rating         :integer          default(0)
#  weekly_streak         :integer          default(0)
#  daily_rating          :integer          default(0)
#  daily_streak          :integer          default(0)
#  real_name             :string(255)
#  mobile_number         :string(255)
#  email                 :string(255)
#  credits               :integer          default(24), not null
#  prize_points          :integer          default(0), not null
#  login                 :string(255)
#  lock_version          :integer          default(0), not null
#  current_daily_streak  :integer          default(0), not null
#  current_weekly_streak :integer          default(0), not null
#  daily_wins            :integer          default(0), not null
#  weekly_wins           :integer          default(0), not null
#  show_hangman          :boolean          default(TRUE)
#  winners_count         :integer          default(0), not null
#

require 'spec_helper'
require 'timecop'

describe User do
  describe "Validation" do
    it "must have a provider" do
      User.new.should have(1).errors_on(:provider)
      User.new(provider: 'xx').should have(0).errors_on(:provider)
    end

    it "must have a uid" do
      User.new.should have(1).errors_on(:uid)
      User.new(uid: 'xx').should have(0).errors_on(:uid)
    end

    it "must have a unique uid per provider" do
      create(:user, uid: "xx", provider: "yy")
      User.new(uid: 'xx', provider: "yy").should have(1).errors_on(:uid)
      User.new(uid: 'xx', provider: "zz").should have(0).errors_on(:uid)
    end
  end

  describe "calculate_daily_rating" do
    it "must use 12 games in the last day" do
      user = create(:user)
      create_list(:game, 13,  score: 1, user: user)
      user.calculate_daily_rating.should == 12
    end

    it "must use games only from today" do
      user = create(:user)
      create(:game, score: 20, user: user)
      Timecop.freeze(1.day.ago) do
        create(:game, score: 20, user: user)
      end
      user.calculate_daily_rating.should == 20
    end

    it "must use first scoring games in the last day" do
      user = create(:user)
      create_list(:game, 12,  score: 1, user: user)
      create(:game, score: 21, user: user)
      user.calculate_daily_rating.should == 12
    end
  end

  describe "calculate_weekly_rating" do
    it "must use 75 games in the last week" do
      user = create(:user)
      create_list(:game, 76,  score: 1, user: user)
      user.calculate_weekly_rating.should == 75
    end

    it "must use games only from this week" do
      user = create(:user)
      create(:game, score: 20, user: user)
      Timecop.freeze(1.week.ago - 1.day) do
        create(:game, score: 20, user: user)
      end
      user.calculate_weekly_rating.should == 20
    end

    it "must use first scoring games in the last week" do
      user = create(:user)
      create_list(:game, 75,  score: 1, user: user)
      create(:game, score: 21, user: user)
      user.calculate_weekly_rating.should == 75
    end
  end

  describe "calculate_score" do
    it "must update the ratings" do
      user = stub_model(User)
      user.stub(:calculate_daily_rating).and_return(10)
      user.stub(:calculate_weekly_rating).and_return(20)
      user.update_ratings
      user.daily_rating.should == 10
      user.weekly_rating.should == 20
    end

    it "must update the daily scores" do
      user = stub_model(User)
      user.should_receive(:calculate_daily_rating).and_return(10)
      user.update_daily_scores
      user.daily_rating.should == 10
    end

    it "must update weekly scores" do
      user = stub_model(User)
      user.stub(:calculate_weekly_rating).and_return(20)
      user.stub(:calculate_weekly_score).and_return(200)
      user.update_ratings
      user.weekly_rating.should == 20
    end
  end

  describe "new_day_set_scores!" do
    it "must set all daily scores to 0" do
      user = create(:user,daily_wins: 10, daily_rating: 11, daily_streak: 13, current_daily_streak: 14)
      User.new_day_set_scores!
      user.reload
      user.daily_wins.should == 0
      user.daily_rating.should == 0
      user.daily_streak.should == 0
      user.current_daily_streak.should == 0
    end

    it "must set all weekly scores to 0 if beginning of week" do
      user = create(:user,weekly_wins: 10, weekly_rating: 11,
                    weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week) do
        User.new_day_set_scores!
        user.reload
        user.weekly_wins.should == 0
        user.weekly_rating.should == 0
        user.weekly_streak.should == 0
        user.current_weekly_streak.should == 0
      end
    end

    it "wont set all weekly scores to 0 if not beginning of week" do
      user = create(:user,weekly_wins: 10, weekly_rating: 11,
                    weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week + 2.days) do
        User.new_day_set_scores!
        user.reload
        user.weekly_wins.should == 10
        user.weekly_rating.should == 11
        user.weekly_streak.should == 13
        user.current_weekly_streak.should == 14
      end
    end

    it "must set all weekly scores to 0 if week forced" do
      user = create(:user,weekly_rating: 11, weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week + 2.days) do
        User.new_day_set_scores!(true)
        user.reload
        user.weekly_rating.should == 0
        user.weekly_streak.should == 0
        user.current_weekly_streak.should == 0
      end
    end
  end

  describe "rank" do
    it "should return correct rankings" do
      user1, user3, user2 = create(:user, weekly_rating: 20), create(:user, weekly_rating: 40), create(:user, weekly_rating: 30)
      user1.rank(:weekly_rating).should == 3
      user3.rank(:weekly_rating).should == 1
      user2.rank(:weekly_rating).should == 2
    end
  end

  describe "find_or_create_from_auth_hash" do
    it "must create a new user if no uid and provider match exists" do
      expect {
        user = User.find_or_create_from_auth_hash(uid: "u", provider: "p", info: {name: "Grant"})
        user.uid.should == 'u'
        user.provider.should == 'p'
        user.name.should == 'Grant'
      }.to change(User, :count).by(1)
    end

    it "must return existing user if uid and provider match exists" do
      user_id = create(:user, uid: "u1", provider: "p", name: "Pawel").id
      expect {
        user = User.find_or_create_from_auth_hash(uid: "u1", provider: "p", info: {name: "Grant"})
        user.uid.should == 'u1'
        user.provider.should == 'p'
        user.id == user_id
      }.to change(User, :count).by(0)
    end

    it "must return nil if no uid" do
      User.find_or_create_from_auth_hash(uid: "", provider: "p", info: {name: "Grant"}).should be_nil
    end

    it "must return nil if no provider" do
      User.find_or_create_from_auth_hash(uid: "u", provider: "", info: {name: "Grant"}).should be_nil
    end
  end

  describe "umta" do
    it "must return proper encoded google umta" do
      user = stub_model(User)
      user.utma.should match(/1\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.15/)
    end

    it "must update umta if inactive for a hour" do
      user = stub_model(User)
      last_utma = user.utma(true)
      Timecop.freeze(1.hour.from_now + 5.minutes) do
        user.utma(true).should_not == last_utma
      end
      user = stub_model(User)
      expect{
        sleep 1; user.utma(false)
      }.to_not change(user,:utma)
    end
  end

  describe "registered_on_mxit_money?" do
    before :each do
      @mxit_money_connection = double("connection", :user_info => {:is_registered => false})
      MxitMoneyApi.stub(:connect).and_return(@mxit_money_connection)
      @user = stub_model(User, :uid => 'm111')
    end

    it "must connect to MxitMoneyApi" do
      MxitMoneyApi.should_receive(:connect).with(ENV['MXIT_MONEY_API_KEY']).and_return(@mxit_money_connection)
      @user.registered_on_mxit_money?
    end

    it "must check the user_info with uid" do
      @mxit_money_connection.should_receive(:user_info).with(:id => 'm111').and_return({})
      @user.registered_on_mxit_money?
    end

    it "wont be registered on mxit money if is_registered is false" do
      @user.should_not be_registered_on_mxit_money
    end
  end

  describe "send_message" do
    it "must use message sender" do
      sender = double("send")
      UserSendMessage.should_receive(:new).with("Nobody!!",[]).and_return(sender)
      sender.should_receive(:send_all)
      User.send_message("Nobody!!",[])
    end
  end

  describe "daily_wins" do
    before :each do
      @user = create(:user)
    end

    it "starts at zero" do
      @user.daily_wins.should == 0
    end

    it "should have 1 after 1 win" do
      create(:won_game, :user => @user)
      @user.daily_wins.should == 1
    end

    it "should have 2 after 2 wins" do
      create_list(:won_game,2, :user => @user)
      @user.daily_wins.should == 2
    end
  end

  describe "weekly_wins" do
    before :each do
      @user = create(:user)
    end

    it "starts at zero" do
      @user.weekly_wins.should == 0
    end

    it "should have 1 after 1 win" do
      create(:won_game, :user => @user)
      @user.weekly_wins.should == 1
    end

    it "should have 2 after 2 wins" do
      create_list(:won_game,2, :user => @user)
      @user.weekly_wins.should == 2
    end
  end

  describe "reset_current_daily_streak" do
    it "must set current_daily_streak to 0" do
      user = User.new
      user.current_daily_streak = 2
      lambda{
        user.reset_streak
      }.should change(user,:current_daily_streak).from(2).to(0)
    end
  end

  describe "increment_current_daily_streak" do
    it "must set current_daily_streak to 3" do
      user = User.new
      user.current_daily_streak = 2
      lambda{
        user.increment_streak
      }.should change(user,:current_daily_streak).from(2).to(3)
    end

    it "must set daily_streak to 3" do
      user = User.new
      user.current_daily_streak = 2
      lambda{
        user.increment_streak
      }.should change(user,:daily_streak).to(3)
    end

    it "wont change daily_streak" do
      user = User.new
      user.daily_streak = 4
      user.current_daily_streak = 2
      lambda{
        user.increment_streak
      }.should_not change(user,:daily_streak)
    end
  end

  describe "daily_streak" do
    before :each do
      @user = create(:user)
    end

    it "starts at zero" do
      @user.daily_streak.should == 0
    end

    it "should have a streak of 1 after 1 win" do
      create(:won_game, :user => @user)
      @user.daily_streak.should == 1
    end

    it "should have a streak of 2 after 2 wins" do
      create_list(:won_game,2, :user => @user)
      @user.daily_streak.should == 2
    end

    it "should have a streak of 1 after 1 win and 1 loss" do
      create(:won_game, :user => @user)
      create(:lost_game, :user => @user)
      @user.daily_streak.should == 1
    end

    it "should have a streak of 2 after 1 win and 1 loss and 2 wins" do
      create(:won_game, :user => @user)
      create(:lost_game, :user => @user)
      create_list(:won_game, 2, :user => @user)
      @user.daily_streak.should == 2
    end
  end

  describe "reset_current_weekly_streak" do
    it "must set current_weekly_streak to 0" do
      user = User.new
      user.current_weekly_streak = 2
      lambda{
        user.reset_streak
      }.should change(user,:current_weekly_streak).from(2).to(0)
    end
  end

  describe "increment_current_weekly_streak" do
    it "must set current_weekly_streak to 3" do
      user = User.new
      user.current_weekly_streak = 2
      lambda{
        user.increment_streak
      }.should change(user,:current_weekly_streak).from(2).to(3)
    end

    it "must set daily_streak to 3" do
      user = User.new
      user.current_weekly_streak = 2
      lambda{
        user.increment_streak
      }.should change(user,:weekly_streak).to(3)
    end

    it "wont change daily_streak" do
      user = User.new
      user.weekly_streak = 4
      user.current_weekly_streak = 2
      lambda{
        user.increment_streak
      }.should_not change(user,:weekly_streak)
    end
  end

  describe "weekly_streak" do
    before :each do
      @user = create(:user)
    end

    it "starts at zero" do
      @user.weekly_streak.should == 0
    end

    it "should have a streak of 1 after 1 win" do
      create(:won_game, :user => @user)
      @user.weekly_streak.should == 1
    end

    it "should have a streak of 2 after 2 wins" do
      create_list(:won_game,2, :user => @user)
      @user.weekly_streak.should == 2
    end

    it "should have a streak of 1 after 1 win and 1 loss" do
      create(:won_game, :user => @user)
      create(:lost_game, :user => @user)
      @user.weekly_streak.should == 1
    end

    it "should have a streak of 2 after 1 win and 1 loss and 2 wins" do
      create(:won_game, :user => @user)
      create(:lost_game, :user => @user)
      create_list(:won_game, 2, :user => @user)
      @user.weekly_streak.should == 2
    end
  end

  describe "daily_wins_required_for_random" do
    before :each do
      @user = create(:user)
    end

    it "must return 5" do
      @user.daily_wins_required_for_random.should == 5
    end

    it "must return 1" do
      create_list(:won_game,4, :user => @user)
      @user.daily_wins_required_for_random.should == 1
    end

    it "must return 0" do
      create_list(:won_game,11, :user => @user)
      @user.daily_wins_required_for_random.should == 0
    end
  end

  describe "weekly_wins_required_for_random" do
    before :each do
      @user = create(:user)
    end

    it "must return 35" do
      @user.weekly_wins_required_for_random.should == 15
    end

    it "must return 26" do
      create_list(:won_game,9, :user => @user)
      @user.weekly_wins_required_for_random.should == 6
    end

    it "must return 0" do
      create_list(:won_game,36, :user => @user)
      @user.weekly_wins_required_for_random.should == 0
    end
  end

  describe "account" do
    before :each do
      @user = create(:user, uid: 'grant', provider: 'mxit')
    end

    it "must find user account based on uid and provider" do
      create(:user_account, uid: 'clive', provider: 'mxit')
      create(:user_account, uid: 'grant', provider: 'facebook')
      user_account = create(:user_account, uid: 'grant', provider: 'mxit')
      @user.account.should == user_account
    end

    it "should not reload account if loaded before" do
      user_account = create(:user_account, uid: 'grant', provider: 'mxit', real_name: 'Grant')
      @user.account
      user_account.update_attributes(real_name: 'Kim')
      @user.account.real_name.should == 'Grant'
    end

    it "must create account if it does not exist and set default values" do
      @user.update_attributes(real_name: 'Grant',
                              mobile_number: '000',
                              email: 'grant@example.com',
                              credits: 111,
                              prize_points: 123)
      user_account = @user.account
      user_account.should_not be_nil
      user_account.real_name.should == 'Grant'
      user_account.mobile_number.should == '000'
      user_account.email.should == 'grant@example.com'
      user_account.credits.should == 111
      user_account.prize_points.should == 123
    end
  end

  describe "account_credits" do
    it "must return the accounts credits" do
      user = create(:user, uid: 'grant', provider: 'mxit')
      user_account = create(:user_account, uid: 'grant', provider: 'mxit', credits: 11)
      user.account_credits.should == 11
    end
  end
end
