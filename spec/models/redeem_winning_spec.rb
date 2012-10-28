require 'spec_helper'

describe RedeemWinning do

  context "Validation" do

    it "must have a prize type" do
      RedeemWinning.new.should have(1).errors_on(:prize_type)
      RedeemWinning.new(prize_type: 'clue_points').should have(0).errors_on(:prize_type)
    end

    it "must have a valid prize type" do
      ['clue_points','moola','vodago_airtime'].each do |t|
        RedeemWinning.new(prize_type: t).should have(0).errors_on(:prize_type)
      end
      ['nonsense'].each do |t|
        RedeemWinning.new(prize_type: t).should have(1).errors_on(:prize_type)
      end
    end

    it "must have a valid prize_amount" do
      RedeemWinning.new.should have(1).errors_on(:prize_amount)
      RedeemWinning.new(prize_amount: 0).should have(1).errors_on(:prize_amount)
      RedeemWinning.new(prize_amount: 1).should have(0).errors_on(:prize_amount)
    end

    it "must have a user_id" do
      RedeemWinning.new.should have(1).errors_on(:user_id)
      RedeemWinning.new(user_id: 1).should have(0).errors_on(:user_id)
    end

    it "must have a user with enough prize_points" do
      user = create(:user, prize_points: 9)
      RedeemWinning.new(user_id: user.id, prize_amount: 10).should have(1).errors_on(:user_id)
      user = create(:user, prize_points: 10)
      RedeemWinning.new(user_id: user.id, prize_amount: 10).should have(0).errors_on(:user_id)
    end

    it "must have a valid state" do
      RedeemWinning.new.should have(1).errors_on(:state)
      ['pending','paid'].each do |t|
        RedeemWinning.new(state: t).should have(0).errors_on(:state)
      end
    end

  end

  context "update user" do

    it "must reduce user prize points after create" do
      user = create(:user, prize_points: 11)
      RedeemWinning.create!(user_id: user.id, prize_amount: 10, prize_type: 'clue_points', state: 'pending')
      user.reload
      user.prize_points.should == 1
    end

    it "must change the status to paid" do
      user = create(:user, prize_points: 11)
      redeem_winning = RedeemWinning.new(user_id: user.id, prize_amount: 10, prize_type: 'clue_points', state: 'pending')
      expect {
        redeem_winning.save
      }.to change(redeem_winning,:state).from('pending').to('paid')
    end

    it "must change the status to paid" do
      user = create(:user, prize_points: 11)
      redeem_winning = RedeemWinning.new(user_id: user.id, prize_amount: 10, prize_type: 'clue_points', state: 'pending')
      expect {
        redeem_winning.save
      }.to change{user.reload;user.clue_points}.by(10)
    end

  end

end
