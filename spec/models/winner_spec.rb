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

  it "must have a end_of_period_on" do
    Winner.new.should have(1).errors_on(:end_of_period_on)
    Winner.new(end_of_period_on: Date.today).should have(0).errors_on(:end_of_period_on)
  end

  context "create_winners_for_category" do

    before :each do
      User.should respond_to(:send_message)
      User.stub(:send_message)
    end

    ['rating','precision','wins'].each do |score_by|

      ['daily','weekly','monthly'].each do |period|

        context "#{period} #{score_by}" do

          it "must select the top 10 players" do
            create_list(:user,10, "#{period}_#{score_by}" => 9)
            top_players = create_list(:user,10, "#{period}_#{score_by}" => 10)
            Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [10] * 10)
            top_players.each do |user|
              user.should have(1).winners_for_period_and_reason(period,score_by)
              winner = user.winners_for_period_and_reason(period,score_by).first
              winner.period.should == period
              winner.end_of_period_on.should == Date.today
              winner.amount.should == 10
              winner.reason.should == score_by
            end
          end

          it "must give players that scored the same, the same amount" do
            users_with_10 = create_list(:user,2, "#{period}_#{score_by}" => 10)
            users_with_9 = create_list(:user,3, "#{period}_#{score_by}" => 9)
            users_with_8 = create_list(:user,5, "#{period}_#{score_by}" => 8)
            Winner.create_winners_for_category(period: period, score_by: score_by, winnings:[10,9,8,7,6,5,4,3,2,1])
            [[users_with_10,10],[users_with_9,8],[users_with_8,5]].each do |users,amount|
              users.each do |user|
                user.should have(1).winners_for_period_and_reason(period,score_by)
                winner = user.winners_for_period_and_reason(period,score_by).first
                winner.amount.should == amount
              end
            end
          end

          it "must send the players a message" do
            user = create(:user, "#{period}_#{score_by}" =>  10)
            User.should_receive(:send_message).
              with(anything(),[user])
            Winner.create_winners_for_category(period: period, score_by: score_by, winnings:[10] * 10)
          end

          it "must increase user prize points" do
            users = create_list(:user,10, "#{period}_#{score_by}" => 10)
            Winner.create_winners_for_category(period: period, score_by: score_by, winnings:[8] * 10)
            users.each do |user|
              user.reload
              user.prize_points.should == 8
            end
          end

        end

      end

    end

  end

  context "create_daily_winners" do

    before :each do
      create_list(:user,10, daily_rating: 0, daily_precision: 0, daily_wins: 0)
      Winner.should respond_to(:create_winners_for_category)
      Winner.stub(:create_winners_for_category)
      User.should respond_to(:send_message)
      User.stub(:send_message)
    end

    it "must create the rating winner" do
      Winner.should_receive(:create_winners_for_category).with(period: 'daily', score_by: 'rating',winnings: [10] * 10)
      Winner.create_daily_winners([10] * 10)
    end

    it "must create the precision winner" do
      Winner.should_receive(:create_winners_for_category).with(period: 'daily', score_by: 'precision',winnings:(1..10).to_a.reverse)
      Winner.create_daily_winners((1..10).to_a.reverse)
    end

    it "must create the wins winner" do
      Winner.should_receive(:create_winners_for_category).with(period: 'daily', score_by: 'wins',winnings: (11..20).to_a.reverse)
      Winner.create_daily_winners((11..20).to_a.reverse)
    end

    it "must send a message to everyone" do
      User.should_receive(:send_message).
        with("We have selected our $winners$ for the daily prizes, Congratulations to those who have won.")
      Winner.create_daily_winners((11..20).to_a.reverse)
    end

    it "wont create new winners if they already exist for period" do
      Winner.should_not_receive(:create_winners_for_category)
      create(:winner, period: 'daily', end_of_period_on: Date.today)
      Winner.create_daily_winners((11..20).to_a.reverse)
    end

  end

end
