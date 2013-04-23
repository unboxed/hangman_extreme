require 'spec_helper'

describe RedeemWinning do

  context "Validation" do

    ['clue_points','vodago_airtime','cell_c_airtime','mtn_airtime',
     'mxit_money','virgin_airtime','heita_airtime'].each do |t|
      it "must accept #{t} as valid prize type" do
        RedeemWinning.new(prize_type: t).should have(0).errors_on(:prize_type)
      end
    end

    it "wont accept invalid prize type" do
      RedeemWinning.new(prize_type: 'nonsense').should have(1).errors_on(:prize_type)
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
    end

    ['pending','cancelled','paid'].each do |t|
      it "must accept #{t} as valid state" do
        RedeemWinning.new(state: t).should have(0).errors_on(:state)
      end
    end

  end

  context "scopes" do

    describe "pending_mxit_money" do

      it "must include a pending mxit money" do
        winning = create(:redeem_winning, prize_amount: 10, prize_type: 'mxit_money', state: 'pending')
        RedeemWinning.pending_mxit_money.should include(winning)
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

  end

  context "paid!" do

    it "must update state to paid" do
      winning = create(:redeem_winning, prize_amount: 10, prize_type: 'vodago_airtime', state: 'pending')
      RedeemWinning.paid!(winning.id)
      winning.reload
      winning.should be_paid
    end

  end

  context "issue_mxit_money" do

    after :each do
      IssueMxitMoneyToUsers.jobs.clear
    end

    it "must create background job to issue the money" do
      expect {
        create(:redeem_winning, prize_amount: 10, prize_type: 'mxit_money', state: 'pending')
      }.to change(IssueMxitMoneyToUsers.jobs, :size).by(1)
    end

    it "wont create background job to issue mxit money for other jobs" do
      expect {
        create(:redeem_winning, prize_amount: 10, prize_type: 'vodago_airtime', state: 'pending')
      }.to_not change(IssueMxitMoneyToUsers.jobs, :size)
    end

  end

  context "issue_airtime" do

    after :each do
      IssueAirtimeToUsers.jobs.clear
    end

    it "wont create background job to issue mxit money" do
      expect {
        create(:redeem_winning, prize_amount: 10, prize_type: 'mxit_money', state: 'pending')
      }.to_not change(IssueAirtimeToUsers.jobs, :size).by(1)
    end

    it "must create background job to issue vodago airtime" do
      expect {
        create(:redeem_winning, prize_amount: 10, prize_type: 'vodago_airtime', state: 'pending')
      }.to change(IssueAirtimeToUsers.jobs, :size).by(1)
    end

    it "must create background job to issue mtn airtime" do
      expect {
        create(:redeem_winning, prize_amount: 10, prize_type: 'mtn_airtime', state: 'pending')
      }.to change(IssueAirtimeToUsers.jobs, :size).by(1)
    end

  end

end
