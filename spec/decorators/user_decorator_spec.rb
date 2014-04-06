require 'spec_helper'

describe UserDecorator do

  before :each do
    @user = stub_model(User)
  end

  let(:decorator){@user.decorate}

  describe 'daily_random' do

    it 'must check user daily_wins_required_for_random' do
      @user.should_receive(:daily_wins_required_for_random).and_return(5)
      decorator.daily_random
    end

    it 'must show text 5 more games' do
      @user.stub(:daily_wins_required_for_random).and_return(5)
      decorator.daily_random.should == '5 more games'
    end

    it 'must show text 1 more game' do
      @user.stub(:daily_wins_required_for_random).and_return(1)
      decorator.daily_random.should == '1 more game'
    end

    it 'must show text entered' do
      @user.stub(:daily_wins_required_for_random).and_return(0)
      decorator.daily_random.should == 'Entered'
    end

  end

  describe 'weekly_random' do


    it 'must check user weekly_wins_required_for_random' do
      @user.should_receive(:weekly_wins_required_for_random).and_return(5)
      decorator.weekly_random
    end

    it 'must show text 5 more games' do
      @user.stub(:weekly_wins_required_for_random).and_return(5)
      decorator.weekly_random.should == '5 more games'
    end

    it 'must show text 1 more game' do
      @user.stub(:weekly_wins_required_for_random).and_return(1)
      decorator.weekly_random.should == '1 more game'
    end

    it 'must show text entered' do
      @user.stub(:weekly_wins_required_for_random).and_return(0)
      decorator.weekly_random.should == 'Entered'
    end

  end

  describe 'daily_streak_rank' do

    it 'must be 1st' do
      @user.should_receive(:rank).with('daily_streak').and_return(1)
      decorator.daily_streak_rank.should == '1st'
    end

    it 'must be 3rd' do
      @user.should_receive(:rank).with('daily_streak').and_return(3)
      decorator.daily_streak_rank.should == '3rd'
    end

  end

  describe 'daily_rating_rank' do

    it 'must be 1st' do
      @user.should_receive(:rank).with('daily_rating').and_return(1)
      decorator.daily_rating_rank.should == '1st'
    end

    it 'must be 3rd' do
      @user.should_receive(:rank).with('daily_rating').and_return(3)
      decorator.daily_rating_rank.should == '3rd'
    end

  end

  describe 'daily_random_rank' do

    it 'must be empty' do
      decorator.daily_random_rank.should == ''
    end

  end

  describe 'weekly_streak_rank' do

    it 'must be 1st' do
      @user.should_receive(:rank).with('weekly_streak').and_return(1)
      decorator.weekly_streak_rank.should == '1st'
    end

    it 'must be 3rd' do
      @user.should_receive(:rank).with('weekly_streak').and_return(3)
      decorator.weekly_streak_rank.should == '3rd'
    end

  end

  describe 'weekly_rating_rank' do

    it 'must be 1st' do
      @user.should_receive(:rank).with('weekly_rating').and_return(1)
      decorator.weekly_rating_rank.should == '1st'
    end

    it 'must be 3rd' do
      @user.should_receive(:rank).with('weekly_rating').and_return(3)
      decorator.weekly_rating_rank.should == '3rd'
    end

  end

  describe 'weekly_random_rank' do

    it 'must be empty' do
      decorator.weekly_random_rank.should == ''
    end

  end

end
