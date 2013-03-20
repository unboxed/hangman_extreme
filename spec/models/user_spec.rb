require 'spec_helper'

describe User do

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

  context "calculate_daily_precision" do

    it "must use the attempts left per game" do
      user = create(:user)
      create_list(:won_game,9, word: "test", choices: "tes", user: user)
      create(:won_game, word: "test", choices: "ters", user: user)
      user.calculate_daily_precision.should == 99
    end

    it "must use only completed games" do
      user = create(:user)
      create_list(:won_game,10, word: "test", choices: "tes", user: user)
      create(:game, word: "test", choices: "ter", user: user)
      user.calculate_daily_precision.should == 100
    end

    it "must use games only from today" do
      user = create(:user)
      create_list(:won_game,10, word: "test", choices: "tes", user: user)
      Timecop.freeze(1.day.ago) do
        create(:won_game, word: "test", choices: "ters", user: user)
      end
      user.calculate_daily_precision.should == 100
    end

    it "must return 0 if less than 10 games played" do
      user = create(:user)
      create_list(:won_game,9, word: "test", choices: "tes", user: user)
      user.calculate_daily_precision.should == 0
    end

  end

  context "calculate_weekly_precision" do

    it "must use the attempts left per game" do
      user = create(:user)
      create_list(:won_game,34, word: "test", choices: "tes", user: user)
      create(:won_game, word: "test", choices: "ters", user: user)
      user.calculate_weekly_precision.should == 99
    end

    it "must use only completed games" do
      user = create(:user)
      create_list(:won_game,35, word: "test", choices: "tes", user: user)
      create(:game, word: "test", choices: "ter", user: user)
      user.calculate_weekly_precision.should == 100
    end

    it "must use games only from this week" do
      user = create(:user)
      create_list(:won_game,35, word: "test", choices: "tes", user: user)
      Timecop.freeze(1.week.ago - 1.day) do
        create(:won_game, word: "test", choices: "ters", user: user)
      end
      user.calculate_weekly_precision.should == 100
    end

    it "must return 0 if less than 35 games played" do
      user = create(:user)
      create_list(:won_game,34, word: "test", choices: "tes", user: user)
      user.calculate_weekly_precision.should == 0
    end

  end

  context "calculate_daily_rating" do

    it "must use 10 games in the last day" do
      user = create(:user)
      create_list(:game, 11,  score: 1, user: user)
      user.calculate_daily_rating.should == 10
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
      create_list(:game, 10,  score: 1, user: user)
      create(:game, score: 21, user: user)
      user.calculate_daily_rating.should == 10
    end

  end

  context "calculate_weekly_rating" do

    it "must use 35 games in the last week" do
      user = create(:user)
      create_list(:game, 36,  score: 1, user: user)
      user.calculate_weekly_rating.should == 35
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
      create_list(:game, 35,  score: 1, user: user)
      create(:game, score: 21, user: user)
      user.calculate_weekly_rating.should == 35
    end

  end

  context "calculate_score" do

    it "must update the ratings" do
      user = stub_model(User)
      user.stub(:calculate_daily_rating).and_return(10)
      user.stub(:calculate_weekly_rating).and_return(20)
      user.stub(:calculate_daily_precision).and_return(75)
      user.stub(:calculate_weekly_precision).and_return(100)
      user.update_ratings
      user.daily_rating.should == 10
      user.weekly_rating.should == 20
      user.daily_precision.should == 75
      user.weekly_precision.should == 100
    end

    it "must update the daily scores" do
      user = stub_model(User)
      user.should_receive(:calculate_daily_rating).and_return(10)
      user.should_receive(:calculate_daily_precision).and_return(75)
      user.update_daily_scores
      user.daily_rating.should == 10
      user.daily_precision.should == 75
    end

    it "must update weekly scores" do
      user = stub_model(User)
      user.stub(:calculate_weekly_rating).and_return(20)
      user.stub(:calculate_weekly_precision).and_return(100)
      user.stub(:calculate_weekly_score).and_return(200)
      user.update_ratings
      user.weekly_rating.should == 20
      user.weekly_precision.should == 100
    end

  end

  context "add_clue_point_to_active_players!" do

    it "must increases users clue_points who played today by one" do
      user = create(:game, user: create(:user, clue_points: 2)).user
      User.add_clue_point_to_active_players!
      user.reload
      user.clue_points.should == 3
    end

    it "wont increases users clue_points who did not play today" do
      user = create(:user, clue_points: 2)
      Timecop.freeze(1.day.ago) do
        create(:game, user: user)
      end
      User.add_clue_point_to_active_players!
      user.reload
      user.clue_points.should == 2
    end

  end

  context "new_day_set_scores!" do

    it "must set all daily scores to 0" do
      user = create(:user,daily_rating: 11, daily_precision: 12, daily_streak: 13, current_daily_streak: 14)
      User.new_day_set_scores!
      user.reload
      user.daily_rating.should == 0
      user.daily_precision.should == 0
      user.daily_streak.should == 0
      user.current_daily_streak.should == 0
    end

    it "must set all weekly scores to 0 if beginning of week" do
      user = create(:user,weekly_rating: 11, weekly_precision: 12, weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week) do
        User.new_day_set_scores!
        user.reload
        user.weekly_rating.should == 0
        user.weekly_precision.should == 0
        user.weekly_streak.should == 0
        user.current_weekly_streak.should == 0
      end
    end

    it "wont set all weekly scores to 0 if not beginning of week" do
      user = create(:user,weekly_rating: 11, weekly_precision: 12, weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week + 2.days) do
        User.new_day_set_scores!
        user.reload
        user.weekly_rating.should == 11
        user.weekly_precision.should == 12
        user.weekly_streak.should == 13
        user.current_weekly_streak.should == 14
      end
    end

    it "must set all weekly scores to 0 if week forced" do
      user = create(:user,weekly_rating: 11, weekly_precision: 12, weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week + 2.days) do
        User.new_day_set_scores!(true)
        user.reload
        user.weekly_rating.should == 0
        user.weekly_precision.should == 0
        user.weekly_streak.should == 0
        user.current_weekly_streak.should == 0
      end
    end

  end

  context "update_scores!" do

    it "must set all scores for players who have played today" do
      scoring_fields = User.scoring_fields.delete_if{|s| s.to_s.include?('streak')}
      Timecop.freeze(2013, 4, 1,1) do # Monday 1st April
        user = create(:user)
        create_list(:won_game,20, user: user)
        user.update_ratings
        scores = scoring_fields.collect{|field| [field,user.send(field.to_sym)] }
        User.new_day_set_scores!
        User.update_scores!
        user.reload
        new_scores = scoring_fields.collect{|field| [field,user.send(field.to_sym)] }
        scores.each do |score|
          new_scores.should include(score)
        end
      end
    end

  end

  context "rank" do

    it "should return correct rankings" do
      user1, user3, user2 = create(:user, weekly_rating: 20), create(:user, weekly_rating: 40), create(:user, weekly_rating: 30)
      user1.rank(:weekly_rating).should == 3
      user3.rank(:weekly_rating).should == 1
      user2.rank(:weekly_rating).should == 2
    end

  end

  context "find_or_create_from_auth_hash" do

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

  context "umta", :redis => true do

    it "must return proper encoded google umta" do
      user = stub_model(User)
      user.utma.should match(/1\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.15/)
    end

    it "must update umta if inactive for a hour" do
      user = stub_model(User)
      last_utma = user.utma(true)
      Timecop.freeze(1.hour.from_now + 1.second) do
        user.utma(true).should_not == last_utma
      end
      user = stub_model(User)
      expect{
        sleep 1; user.utma(false)
      }.to_not change(user,:utma)
    end

  end

  context "registered_on_mxit_money?" do

    before :each do
      @mxit_money_connection = mock("connection", :user_info => {:is_registered => false})
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

  context "send_message" do

    before :each do
      MxitApiWrapper.should respond_to(:connect)
      MxitApiWrapper.new(nil).should respond_to(:send_message)
      @mxit_connection = mock('Mxit Connection', :send_message => true)
      MxitApiWrapper.stub(:connect).and_return(@mxit_connection)
    end

    it "must not connect if no users selected" do
      MxitApiWrapper.should_not_receive(:connect)
      User.send_message("Nobody!!",[])
    end

    it "must send a message to a user" do
      user = stub_model(User, uid: 'm345')
      @mxit_connection.should_receive(:send_message).once.with(body: 'Single user', to: "m345")
      User.send_message("Single user",[user])
    end

    it "must break up users into groups of 100" do
      @mxit_connection.should_receive(:send_message).twice
      users = create_list(:user, 101)
      User.send_message("Single user",users)
    end

    it "must work with relations in groups of 100" do
      @mxit_connection.should_receive(:send_message).twice
      create_list(:user, 101, provider: 'mxit')
      User.send_message("Single user",User.mxit)
    end

  end

  context "daily_wins" do

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

  context "weekly_wins" do

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

  context "reset_current_daily_streak" do

    it "must set current_daily_streak to 0" do
      user = User.new
      user.current_daily_streak = 2
      lambda{
        user.reset_streak
      }.should change(user,:current_daily_streak).from(2).to(0)
    end

  end

  context "increment_current_daily_streak" do

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

  context "daily_streak" do

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

  context "reset_current_weekly_streak" do

    it "must set current_weekly_streak to 0" do
      user = User.new
      user.current_weekly_streak = 2
      lambda{
        user.reset_streak
      }.should change(user,:current_weekly_streak).from(2).to(0)
    end

  end

  context "increment_current_weekly_streak" do

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

  context "weekly_streak" do

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

    it "must return 10" do
      @user.daily_wins_required_for_random.should == 10
    end

    it "must return 1" do
      create_list(:won_game,9, :user => @user)
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

    it "must return 10" do
      @user.weekly_wins_required_for_random.should == 35
    end

    it "must return 1" do
      create_list(:won_game,9, :user => @user)
      @user.weekly_wins_required_for_random.should == 26
    end

    it "must return 0" do
      create_list(:won_game,36, :user => @user)
      @user.weekly_wins_required_for_random.should == 0
    end

  end

end
