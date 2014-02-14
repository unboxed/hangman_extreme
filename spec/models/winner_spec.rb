# == Schema Information
#
# Table name: winners
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  reason           :string(255)
#  amount           :integer
#  period           :string(255)
#  end_of_period_on :date
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'
require 'timecop'

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
      UserSendMessage.stub(:send)
    end

    ['daily', 'weekly'].each do |period|
      context "#{period}" do
        context "random" do
          let(:required_wins){period == 'daily' ? 5 : 15}

          it "wont allow players to win 2 randoms in a row" do
            day1 = Time.current.end_of_week
            first_group_of_players = create_list(:user, 5, "#{period}_wins" => required_wins)
            Timecop.freeze(day1) do
              Winner.create_winners_for_category(period: period, score_by: "random", winnings: [10] * 5)
              Winner.period(period).reason("random").count.should == 5
              first_group_of_players.each do |user|
                user.winners.period(period).reason("random").count.should == 1
              end
            end
            second_group_of_players = create_list(:user, 5, "#{period}_wins" => required_wins)
            Timecop.freeze(day1 + (period == 'daily' ? 1.day : 1.week)) do
              Winner.create_winners_for_category(period: period, score_by: "random", winnings: [10] * 5)
              Winner.period(period).reason("random").count.should == 10
              first_group_of_players.each do |user|
                user.winners.period(period).reason("random").count.should == 1
              end
              second_group_of_players.each do |user|
                user.winners.period(period).reason("random").count.should == 1
              end
            end
            Timecop.freeze(day1 + (period == 'daily' ? 2.days : 2.weeks)) do
              Winner.create_winners_for_category(period: period, score_by: "random", winnings: [10] * 5)
              Winner.period(period).reason("random").count.should == 15
              first_group_of_players.each do |user|
                user.winners.period(period).reason("random").count.should == 2
              end
              second_group_of_players.each do |user|
                user.winners.period(period).reason("random").count.should == 1
              end
            end
          end

          it "must select players that have won at least #{period == 'daily' ? 5 : 15} games" do
            create_list(:user, 5, "#{period}_wins" => required_wins - 1)
            top_players = create_list(:user, 5, "#{period}_wins" => required_wins)
            Winner.create_winners_for_category(period: period, score_by: "random", winnings: [10] * 5)
            top_players.each do |user|
              user.winners.period(period).reason("random").count.should == 1
              winner = user.winners.period(period).reason("random").first
              winner.period.should == period
              winner.end_of_period_on.should == Date.current
              winner.amount.should == 10
              winner.reason.should == "random"
            end
          end

          it "must not select from players that have already won in another category" do
            random_players = create_list(:user, 5,
                                         "#{period}_wins" => required_wins,
                                         "#{period}_streak" => 0)
            create_list(:user, 5,
                        "#{period}_wins" => required_wins,
                        "#{period}_streak" => 10 )
            Winner.create_winners_for_category(period: period, score_by: "streak", winnings: [10] * 5)
            Winner.create_winners_for_category(period: period, score_by: "random", winnings: [10] * 5)
            Winner.period(period).reason("random").count.should == 5
            random_players.each do |user|
              user.winners.period(period).reason("random").count.should == 1
              winner = user.winners.period(period).reason("random").first
              winner.amount.should == 10
            end
          end

          it "must prefer players who have not won this week" do
            last_week_winners_players = create_list(:user, 5,
                                                    "#{period}_wins" => required_wins,
                                                    "#{period}_streak" => 10)
            Timecop.freeze(1.week.ago) do
              Winner.create_winners_for_category(period: period, score_by: "streak", winnings: [10] * 5)
            end
            create_list(:user, 5,
                        "#{period}_wins" => required_wins,
                        "#{period}_streak" => 10 )
            Winner.create_winners_for_category(period: period, score_by: "streak", winnings: [10] * 5)
            Winner.create_winners_for_category(period: period, score_by: "random", winnings: [10] * 5)
            Winner.period(period).reason("random").count.should == 5
            last_week_winners_players.each do |user|
              user.winners.period(period).reason("random").count.should == 1
              winner = user.winners.period(period).reason("random").first
              winner.amount.should == 10
            end
          end

          it "must send the players a message" do
            create_list(:user, 5, "#{period}_wins" => required_wins)
            UserSendMessage.should_receive(:send).with(anything(), kind_of(Array))
            Winner.create_winners_for_category(period: period, score_by: "random", winnings: [10] * 5)
          end

          it "must increase user prize points" do
            users = create_list(:user, 5, "#{period}_wins" => required_wins)
            Winner.create_winners_for_category(period: period, score_by: "random", winnings: [8] * 5)
            users.each do |user|
              user.reload
              user.winners.last.amount.should == 8
            end
          end
        end

        ['rating', 'streak'].each do |score_by|
          context "#{score_by}" do
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

            it "must share point if players score the same and has previous winners" do
              (6..11).each{|i|create(:user, "#{period}_#{score_by}" => i)}
              Timecop.freeze(Time.current + (period == 'daily' ? 2.day : 2.week)) do
                Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [10] * 5)
                Winner.period(period).reason(score_by).count.should == 5
              end
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
              UserSendMessage.should_receive(:send).with(anything(), kind_of(Array))
              Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [10] * 5)
            end

            it "must increase user prize points" do
              users = create_list(:user, 5, "#{period}_#{score_by}" => 10)
              Winner.create_winners_for_category(period: period, score_by: score_by, winnings: [8] * 5)
              users.each do |user|
                user.reload
                user.winners.last.amount.should == 8
              end
            end
          end
        end
      end
    end
  end

  context "create_winners" do
    before :each do
      create_list(:user, 10, daily_rating: 0, daily_streak: 0)
      Winner.should respond_to(:create_winners_for_category)
      Winner.stub(:create_winners_for_category)
      UserSendMessage.stub(:send)
    end

    it "must create the rating winner" do
      Winner.should_receive(:create_winners_for_category).with(period: 'daily', score_by: 'rating', winnings: [10] * 10)
      Winner.create_daily_winners([10] * 10)
    end

    it "must create the streak winner" do
      Winner.should_receive(:create_winners_for_category).with(period: 'daily', score_by: 'streak', winnings: (11..20).to_a.reverse)
      Winner.create_daily_winners((11..20).to_a.reverse)
    end

    it "must send a message to everyone" do
      UserSendMessage.should_receive(:send).
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
end
