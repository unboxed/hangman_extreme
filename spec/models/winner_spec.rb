require 'spec_helper'

describe Winner do

  context "Validation" do

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
      Winner.new(period: "monthly").should have(1).errors_on(:period)
      Winner.new(period: "yearly").should have(1).errors_on(:period)
    end

    it "must have a end_of_period_on" do
      Winner.new.should have(1).errors_on(:end_of_period_on)
      Winner.new(end_of_period_on: Date.current).should have(0).errors_on(:end_of_period_on)
    end

  end

  context "create_winners_for_category" do

    before :each do
      User.stub(:send_message)
    end

    ['rating', 'precision', 'streak'].each do |score_by|

      context "#{score_by}" do

        ['daily', 'weekly'].each do |period|

          context "#{period}" do

            it "wont allow players to win 2 #{period}s in a row" do
              day1 = Time.current.end_of_week
              other_players = create_list(:user, 5, "#{period}_#{score_by}" => 9)
              better_players = create_list(:user, 5, "#{period}_#{score_by}" => 10)
              Timecop.freeze(day1) do
                Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [10] * 5)
                Winner.period(period).reason(score_by).count.should == 5
                better_players.each do |user|
                  user.winners.period(period).reason(score_by).count.should == 1
                end
                other_players.each do |user|
                  user.winners.period(period).reason(score_by).count.should == 0
                end
              end
              Timecop.freeze(day1 + (period == 'daily' ? 1.day : 1.week)) do
                Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [10] * 5)
                Winner.period(period).reason(score_by).count.should == 10
                better_players.each do |user|
                  user.winners.period(period).reason(score_by).count.should == 1
                end
                other_players.each do |user|
                  user.winners.period(period).reason(score_by).count.should == 1
                end
              end
              Timecop.freeze(day1 + (period == 'daily' ? 2.day : 2.week)) do
                Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [10] * 5)
                Winner.period(period).reason(score_by).count.should == 15
                better_players.each do |user|
                  user.winners.period(period).reason(score_by).count.should == 2
                end
                other_players.each do |user|
                  user.winners.period(period).reason(score_by).count.should == 1
                end
              end
            end

            it "must select the top 5 players" do
              create_list(:user, 5, "#{period}_#{score_by}" => 9)
              top_players = create_list(:user, 5, "#{period}_#{score_by}" => 10)
              Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [10] * 5)
              top_players.each do |user|
                user.winners.period(period).reason(score_by).count.should == 1
                winner = user.winners.period(period).reason(score_by).first
                winner.period.should == period
                winner.end_of_period_on.should == Date.current
                winner.amount.should == 10
                winner.reason.should == score_by
              end
            end

            it "must share point if players score the same" do
              users_with_10 = create_list(:user, 3, "#{period}_#{score_by}" => 10)
              users_with_9 = create_list(:user, 3, "#{period}_#{score_by}" => 9)
              Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [50, 50, 50, 50, 50])
              [[users_with_10, 50], [users_with_9, 34]].each do |users, amount|
                users.each do |user|
                  user.winners.period(period).reason(score_by).count.should == 1
                  winner = user.winners.period(period).reason(score_by).first
                  winner.amount.should == amount
                end
              end
            end

            it "must send the players a message" do
              create_list(:user, 5, "#{period}_#{score_by}" => 10)
              User.should_receive(:send_message).
                with(anything(), kind_of(Array))
              Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [10] * 5)
            end

            it "must increase user prize points" do
              users = create_list(:user, 5, "#{period}_#{score_by}" => 10)
              Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [8] * 5)
              users.each do |user|
                user.reload
                user.prize_points.should == 8
              end
            end

          end

        end

      end

    end
  end

  context "create_winners" do

    before :each do
      create_list(:user, 10, daily_rating: 0, daily_precision: 0, daily_streak: 0)
      Winner.should respond_to(:create_winners_for_category)
      Winner.stub(:create_winners_for_category)
      User.should respond_to(:send_message)
      User.stub(:send_message)
    end

    it "must create the rating winner" do
      Winner.should_receive(:create_winners_for_category).with(period: 'daily', score_by: 'rating', winnings: [10] * 10)
      Winner.create_daily_winners([10] * 10)
    end

    it "must create the precision winner" do
      Winner.should_receive(:create_winners_for_category).with(period: 'daily', score_by: 'precision', winnings: (1..10).to_a.reverse)
      Winner.create_daily_winners((1..10).to_a.reverse)
    end

    it "must create the streak winner" do
      Winner.should_receive(:create_winners_for_category).with(period: 'daily', score_by: 'streak', winnings: (11..20).to_a.reverse)
      Winner.create_daily_winners((11..20).to_a.reverse)
    end

    it "must send a message to everyone" do
      User.should_receive(:send_message).
        with("We have selected our $winners$ for the daily prizes, Congratulations to those who have won.",
             anything())
      Winner.create_daily_winners((11..20).to_a.reverse)
    end

    it "wont create new winners if they already exist for period" do
      Winner.should_not_receive(:create_winners_for_category)
      create(:winner, period: 'daily', end_of_period_on: Date.current)
      Winner.create_daily_winners((11..20).to_a.reverse)
    end

    it "must run without arguments" do
      Winner.create_daily_winners
    end

    it "must run without arguments" do
      Winner.create_weekly_winners
    end

  end

  context "cohort_array" do

    it "must run" do
      create(:winner)
      Winner.cohort_array.should be_kind_of(Array)
    end

  end

end
