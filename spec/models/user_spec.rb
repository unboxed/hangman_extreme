# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  name                      :text
#  uid                       :string(255)
#  provider                  :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  weekly_rating             :integer          default(0)
#  yearly_rating             :integer          default(0)
#  weekly_streak             :integer          default(0)
#  daily_rating              :integer          default(0)
#  daily_streak              :integer          default(0)
#  _deprecated_real_name     :string(255)
#  _deprecated_mobile_number :string(255)
#  _deprecated_email         :string(255)
#  _deprecated_credits       :integer          default(24), not null
#  _deprecated_prize_points  :integer          default(0), not null
#  _deprecated_login         :string(255)
#  lock_version              :integer          default(0), not null
#  current_daily_streak      :integer          default(0), not null
#  current_weekly_streak     :integer          default(0), not null
#  daily_wins                :integer          default(0), not null
#  weekly_wins               :integer          default(0), not null
#  show_hangman              :boolean          default(TRUE)
#  winners_count             :integer          default(0), not null
#

require 'spec_helper'
require 'timecop'

describe User do
  describe 'Validation' do
    it 'must have a provider' do
      User.new.should have(1).errors_on(:provider)
      User.new(provider: 'xx').should have(0).errors_on(:provider)
    end

    it 'must have a uid' do
      User.new.should have(1).errors_on(:uid)
      User.new(uid: 'xx').should have(0).errors_on(:uid)
    end

    it 'must have a unique uid per provider' do
      create(:user, uid: 'xx', provider: 'yy')
      User.new(uid: 'xx', provider: 'yy').should have(1).errors_on(:uid)
      User.new(uid: 'xx', provider: 'zz').should have(0).errors_on(:uid)
    end
  end

  describe 'calculate_daily_rating' do
    it 'must use 12 games in the last day' do
      user = create(:user)
      create_list(:game, 13,  score: 1, user: user)
      user.calculate_daily_rating.should be == 12
    end

    it 'must use games only from today' do
      user = create(:user)
      create(:game, score: 20, user: user)
      Timecop.freeze(1.day.ago) do
        create(:game, score: 20, user: user)
      end
      user.calculate_daily_rating.should be == 20
    end

    it 'must use first scoring games in the last day' do
      user = create(:user)
      create_list(:game, 12,  score: 1, user: user)
      create(:game, score: 21, user: user)
      user.calculate_daily_rating.should be == 12
    end
  end

  describe 'calculate_weekly_rating' do
    it 'must use 75 games in the last week' do
      user = create(:user)
      create_list(:game, 76,  score: 1, user: user)
      user.calculate_weekly_rating.should be == 75
    end

    it 'must use games only from this week' do
      user = create(:user)
      create(:game, score: 20, user: user)
      Timecop.freeze(1.week.ago - 1.day) do
        create(:game, score: 20, user: user)
      end
      user.calculate_weekly_rating.should be == 20
    end

    it 'must use first scoring games in the last week' do
      user = create(:user)
      create_list(:game, 75,  score: 1, user: user)
      create(:game, score: 21, user: user)
      user.calculate_weekly_rating.should be == 75
    end
  end

  describe 'calculate_score' do
    it 'must update the ratings' do
      user = stub_model(User)
      user.stub(:calculate_daily_rating).and_return(10)
      user.stub(:calculate_weekly_rating).and_return(20)
      user.update_ratings
      user.daily_rating.should be == 10
      user.weekly_rating.should be == 20
    end

    it 'must update the daily scores' do
      user = stub_model(User)
      user.should_receive(:calculate_daily_rating).and_return(10)
      user.update_daily_scores
      user.daily_rating.should be == 10
    end

    it 'must update weekly scores' do
      user = stub_model(User)
      user.stub(:calculate_weekly_rating).and_return(20)
      user.stub(:calculate_weekly_score).and_return(200)
      user.update_ratings
      user.weekly_rating.should be == 20
    end
  end

  describe 'new_day_set_scores!' do
    it 'must set all daily scores to 0' do
      user = create(:user,daily_wins: 10, daily_rating: 11, daily_streak: 13, current_daily_streak: 14)
      User.new_day_set_scores!
      user.reload
      user.daily_wins.should be == 0
      user.daily_rating.should be == 0
      user.daily_streak.should be == 0
      user.current_daily_streak.should be == 0
    end

    it 'must set all weekly scores to 0 if beginning of week' do
      user = create(:user,weekly_wins: 10, weekly_rating: 11,
                    weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week) do
        User.new_day_set_scores!
        user.reload
        user.weekly_wins.should be == 0
        user.weekly_rating.should be == 0
        user.weekly_streak.should be == 0
        user.current_weekly_streak.should be == 0
      end
    end

    it 'wont set all weekly scores to 0 if not beginning of week' do
      user = create(:user,weekly_wins: 10, weekly_rating: 11,
                    weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week + 2.days) do
        User.new_day_set_scores!
        user.reload
        user.weekly_wins.should be == 10
        user.weekly_rating.should be == 11
        user.weekly_streak.should be == 13
        user.current_weekly_streak.should be == 14
      end
    end

    it 'must set all weekly scores to 0 if week forced' do
      user = create(:user,weekly_rating: 11, weekly_streak: 13, current_weekly_streak: 14)
      Timecop.freeze(Time.current.beginning_of_week + 2.days) do
        User.new_day_set_scores!(true)
        user.reload
        user.weekly_rating.should be == 0
        user.weekly_streak.should be == 0
        user.current_weekly_streak.should be == 0
      end
    end
  end

  describe 'rank' do
    it 'should return correct rankings' do
      user1, user3, user2 = create(:user, weekly_rating: 20), create(:user, weekly_rating: 40), create(:user, weekly_rating: 30)
      user1.rank(:weekly_rating).should be == 3
      user3.rank(:weekly_rating).should be == 1
      user2.rank(:weekly_rating).should be == 2
    end
  end

  describe 'find_or_create_from_auth_hash' do
    before :each do
      UserAccount.stub(:find_or_create_with).and_return(double('UserAccount').as_null_object)
    end
    it 'must create a new user if no uid and provider match exists' do
      expect {
        user = User.find_or_create_from_auth_hash(uid: 'u', provider: 'p', info: {name: 'Grant'})
        user.uid.should be == 'u'
        user.provider.should be == 'p'
        user.name.should be == 'Grant'
      }.to change(User, :count).by(1)
    end

    it 'must return existing user if uid and provider match exists' do
      user_id = create(:user, uid: 'u1', provider: 'p', name: 'Pawel').id
      expect {
        user = User.find_or_create_from_auth_hash(uid: 'u1', provider: 'p', info: {name: 'Grant'})
        user.uid.should be == 'u1'
        user.provider.should be == 'p'
        user.id == user_id
      }.to change(User, :count).by(0)
    end

    it 'must return nil if no uid' do
      User.find_or_create_from_auth_hash(uid: '', provider: 'p', info: {name: 'Grant'}).should be_nil
    end

    it 'must return nil if no provider' do
      User.find_or_create_from_auth_hash(uid: 'u', provider: '', info: {name: 'Grant'}).should be_nil
    end
  end

  describe 'umta' do
    it 'must return proper encoded google umta' do
      user = stub_model(User)
      user.utma.should match(/1\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.15/)
    end

    it 'must update umta if inactive for a hour' do
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

  describe 'daily_wins' do
    before :each do
      @user = create(:user)
    end

    it 'starts at zero' do
      @user.daily_wins.should be == 0
    end

    it 'should have 1 after 1 win' do
      create(:won_game, :user => @user)
      @user.daily_wins.should be == 1
    end

    it 'should have 2 after 2 wins' do
      create_list(:won_game,2, :user => @user)
      @user.daily_wins.should be == 2
    end
  end

  describe 'weekly_wins' do
    before :each do
      @user = create(:user)
    end

    it 'starts at zero' do
      @user.weekly_wins.should be == 0
    end

    it 'should have 1 after 1 win' do
      create(:won_game, :user => @user)
      @user.weekly_wins.should be == 1
    end

    it 'should have 2 after 2 wins' do
      create_list(:won_game,2, :user => @user)
      @user.weekly_wins.should be == 2
    end
  end

  describe 'reset_current_daily_streak' do
    it 'must set current_daily_streak to 0' do
      user = User.new
      user.current_daily_streak = 2
      lambda{
        user.reset_streak
      }.should change(user,:current_daily_streak).from(2).to(0)
    end
  end

  describe 'increment_current_daily_streak' do
    it 'must set current_daily_streak to 3' do
      user = User.new
      user.current_daily_streak = 2
      lambda{
        user.increment_streak
      }.should change(user,:current_daily_streak).from(2).to(3)
    end

    it 'must set daily_streak to 3' do
      user = User.new
      user.current_daily_streak = 2
      lambda{
        user.increment_streak
      }.should change(user,:daily_streak).to(3)
    end

    it 'wont change daily_streak' do
      user = User.new
      user.daily_streak = 4
      user.current_daily_streak = 2
      lambda{
        user.increment_streak
      }.should_not change(user,:daily_streak)
    end
  end

  describe 'daily_streak' do
    before :each do
      @user = create(:user)
    end

    it 'starts at zero' do
      @user.daily_streak.should be == 0
    end

    it 'should have a streak of 1 after 1 win' do
      create(:won_game, :user => @user)
      @user.daily_streak.should be == 1
    end

    it 'should have a streak of 2 after 2 wins' do
      create_list(:won_game,2, :user => @user)
      @user.daily_streak.should be == 2
    end

    it 'should have a streak of 1 after 1 win and 1 loss' do
      create(:won_game, :user => @user)
      create(:lost_game, :user => @user)
      @user.daily_streak.should be == 1
    end

    it 'should have a streak of 2 after 1 win and 1 loss and 2 wins' do
      create(:won_game, :user => @user)
      create(:lost_game, :user => @user)
      create_list(:won_game, 2, :user => @user)
      @user.daily_streak.should be == 2
    end
  end

  describe 'reset_current_weekly_streak' do
    it 'must set current_weekly_streak to 0' do
      user = User.new
      user.current_weekly_streak = 2
      lambda{
        user.reset_streak
      }.should change(user,:current_weekly_streak).from(2).to(0)
    end
  end

  describe 'increment_current_weekly_streak' do
    it 'must set current_weekly_streak to 3' do
      user = User.new
      user.current_weekly_streak = 2
      lambda{
        user.increment_streak
      }.should change(user,:current_weekly_streak).from(2).to(3)
    end

    it 'must set daily_streak to 3' do
      user = User.new
      user.current_weekly_streak = 2
      lambda{
        user.increment_streak
      }.should change(user,:weekly_streak).to(3)
    end

    it 'wont change daily_streak' do
      user = User.new
      user.weekly_streak = 4
      user.current_weekly_streak = 2
      lambda{
        user.increment_streak
      }.should_not change(user,:weekly_streak)
    end
  end

  describe 'weekly_streak' do
    before :each do
      @user = create(:user)
    end

    it 'starts at zero' do
      @user.weekly_streak.should be == 0
    end

    it 'should have a streak of 1 after 1 win' do
      create(:won_game, :user => @user)
      @user.weekly_streak.should be == 1
    end

    it 'should have a streak of 2 after 2 wins' do
      create_list(:won_game,2, :user => @user)
      @user.weekly_streak.should be == 2
    end

    it 'should have a streak of 1 after 1 win and 1 loss' do
      create(:won_game, :user => @user)
      create(:lost_game, :user => @user)
      @user.weekly_streak.should be == 1
    end

    it 'should have a streak of 2 after 1 win and 1 loss and 2 wins' do
      create(:won_game, :user => @user)
      create(:lost_game, :user => @user)
      create_list(:won_game, 2, :user => @user)
      @user.weekly_streak.should be == 2
    end
  end

  describe 'daily_wins_required_for_random' do
    before :each do
      @user = create(:user)
    end

    it 'must return 5' do
      @user.daily_wins_required_for_random.should be == 5
    end

    it 'must return 1' do
      create_list(:won_game,4, :user => @user)
      @user.daily_wins_required_for_random.should be == 1
    end

    it 'must return 0' do
      create_list(:won_game,11, :user => @user)
      @user.daily_wins_required_for_random.should be == 0
    end
  end

  describe 'weekly_wins_required_for_random' do
    before :each do
      @user = create(:user)
    end

    it 'must return 35' do
      @user.weekly_wins_required_for_random.should be == 15
    end

    it 'must return 26' do
      create_list(:won_game,9, :user => @user)
      @user.weekly_wins_required_for_random.should be == 6
    end

    it 'must return 0' do
      create_list(:won_game,36, :user => @user)
      @user.weekly_wins_required_for_random.should be == 0
    end
  end

  describe 'account' do
    before :each do
      @user = create(:user, uid: 'grant', provider: 'mxit')
    end

    it 'must create account if it does not exist and set default values' do
      @user.update_attributes(_deprecated_real_name: 'Grant',
                              _deprecated_mobile_number: '000',
                              _deprecated_email: 'grant@example.com',
                              _deprecated_credits: 111,
                              _deprecated_login: 'gman',
                              _deprecated_prize_points: 123)
      UserAccount.should_receive(:find_or_create_with).with({uid: 'grant',provider: 'mxit'},
                                                            {real_name: 'Grant',
                                                             mobile_number: '000',
                                                             email: 'grant@example.com',
                                                             credits: 111,
                                                             mxit_login: 'gman',
                                                             prize_points: 123}).and_return('test')
      @user.account.should be == 'test'
    end
  end
end

describe 'has_five_game_clues_in_sequence' do

  it 'does not count if a clue was not revealed in sequence' do
    @user = create(:user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => false, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    @user.has_five_game_clues_in_sequence.should be == false
  end 

  it 'same user counts 5 clues_revealed in sequence' do
    @user = create(:user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    @user.has_five_game_clues_in_sequence.should be == true
  end 

  it 'does not count 5 clues_revealed if different user' do
    @user = create(:user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true)
    create(:game, :clue_revealed => true, user: @user)
    create(:game, :clue_revealed => true, user: @user)
    @user.has_five_game_clues_in_sequence.should be == false
  end 
end 

describe 'counting winning games in a row' do

  it 'same user counts 10 games in sequence' do
    @user = create(:user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    @user.has_ten_games_in_sequence.should be == true
  end 

  it 'does not count if a clue was revealed' do
    @user = create(:user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game, :clue_revealed => true, user: @user)
    create(:game,user: @user)    
    @user.has_ten_games_in_sequence.should be == false
  end 

  it 'does not count different users for 10 games in sequence' do
    @user = create(:user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game,user: @user)
    create(:game) 
    create(:game,user: @user)
    create(:game,user: @user)    
    @user.has_ten_games_in_sequence.should be == false
  end 
end 

