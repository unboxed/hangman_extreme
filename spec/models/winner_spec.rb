require 'spec_helper'

describe Winner do

  it "must have a user_id" do
    Winner.new.should have(1).errors_on(:user_id)
    Winner.new(user_id: 1).should have(0).errors_on(:user_id)
  end

  it "must have a amount" do
    Winner.new.should have(1).errors_on(:amount)
    Winner.new(amount: 1).should have(0).errors_on(:amount)
  end

  it "must have a reason" do
    Winner.new.should have(1).errors_on(:reason)
    Winner.new(reason: "hello").should have(0).errors_on(:reason)
  end

  it "must have a valid period" do
    Winner.new.should have(1).errors_on(:period)
    Winner.new(period: "hourly").should have(1).errors_on(:period)
    Winner.new(period: "daily").should have(0).errors_on(:period)
    Winner.new(period: "weekly").should have(0).errors_on(:period)
    Winner.new(period: "monthly").should have(0).errors_on(:period)
    Winner.new(period: "yearly").should have(1).errors_on(:period)
  end

  it "must have a start_of_period_on" do
    Winner.new.should have(1).errors_on(:start_of_period_on)
    Winner.new(start_of_period_on: Date.today).should have(0).errors_on(:start_of_period_on)
  end

  context "create_daily_winners" do

    before :each do
      User.stub(:top_scorers).and_return([])
    end

    it "must create the rating winner" do
      @user = stub_model(User)
      User.should_receive(:top_scorers).with('daily_rating').and_return([@user])
      Winner.create_daily_winners([10] * 10)
      @user.should have(1).winners
      winner = @user.winners.first
      winner.should be_daily
      winner.start_of_period_on.should == Date.today
      winner.amount.should == 10
      winner.reason.should == 'daily_rating'
    end

    it "must create the precision winner" do
      @user = create(:user)
      User.should_receive(:top_scorers).with('daily_precision').and_return([@user])
      Winner.create_daily_winners((1..10).to_a.reverse)
      @user.should have(1).winners
      winner = @user.winners.first
      winner.should be_daily
      winner.start_of_period_on.should == Date.today
      winner.amount.should == 10
      winner.reason.should == 'daily_precision'
    end

    it "must create the wins winner" do
      @user = create(:user)
      User.should_receive(:top_scorers).with('games_won_today').and_return([@user])
      Winner.create_daily_winners((11..20).to_a.reverse)
      @user.should have(1).winners
      winner = @user.winners.first
      winner.should be_daily
      winner.start_of_period_on.should == Date.today
      winner.amount.should == 20
      winner.reason.should == 'games_won_today'
    end

    it "wont create new winners if they already exist for period" do
      create(:winner, period: 'daily', start_of_period_on: Date.today)
      User.should_not_receive(:top_scorers)
      expect {
        Winner.create_daily_winners((11..20).to_a.reverse)
      }.to_not change(Winner, :count)
    end

  end

end
