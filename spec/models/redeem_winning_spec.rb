require 'spec_helper'

describe RedeemWinning do

  context "Validation" do

    it "must have a prize type" do
      RedeemWinning.new.should have(1).errors_on(:prize_type)
      RedeemWinning.new(prize_type: 'clue_points').should have(0).errors_on(:prize_type)
    end

    ['clue_points','moola','vodago_airtime','cell_c_airtime','mtn_airtime','mxit_money'].each do |t|
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

    ['pending','paid'].each do |t|
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

  context "paid!" do

    it "must update state to paid" do
      winning = create(:redeem_winning, prize_amount: 10, prize_type: 'vodago_airtime', state: 'pending')
      RedeemWinning.paid!(winning.id)
      winning.reload
      winning.state.should == 'paid'
    end

  end

  context "issue_mxit_money_to_users" do

    before :each do
      @redeem_winning = stub_model(RedeemWinning, id: 333,
                                                  prize_amount: 23,
                                                  user: stub_model(User, prize_points: 1000,
                                                                         uid: 'm221',
                                                                         paid!: true))
      RedeemWinning.stub!(:pending_mxit_money).and_return([@redeem_winning])
      @mxit_money_connection = mock("connection",
                                    :user_info => {is_registered: true, msisdn: '0713450987'},
                                    :issue_money => {:m2_reference => "ref1"})
      MxitMoneyApi.stub(:connect).and_return(@mxit_money_connection)
    end

    it "must get the mxit_money pending redeem winnings" do
      RedeemWinning.should_receive(:pending_mxit_money).and_return([@redeem_winning])
      RedeemWinning.issue_mxit_money_to_users
    end

    it "must connect to mxit money" do
      MxitMoneyApi.should_receive(:connect).with(ENV['MXIT_MONEY_API_KEY']).and_return(@mxit_money_connection)
      RedeemWinning.issue_mxit_money_to_users
    end

    it "must check the user_info with uid" do
      @mxit_money_connection.should_receive(:user_info).with(:id => 'm221').and_return({})
      RedeemWinning.issue_mxit_money_to_users
    end

    it "must issue money to user" do
      @mxit_money_connection.should_receive(:issue_money).
        with(:phone_number => '0713450987',
             :merchant_reference => "RW333Y#{Time.current.yday}H#{Time.current.hour}",
             :amount_in_cents => 23).and_return({})
      RedeemWinning.issue_mxit_money_to_users
    end

    it "must update to paid!" do
      @redeem_winning.should_receive(:update_attributes).with(:state => 'paid', :mxit_money_reference => "ref1")
      RedeemWinning.issue_mxit_money_to_users
    end

    it "wont update to paid! if issue error" do
      @mxit_money_connection.should_receive(:issue_money).and_return({})
      @redeem_winning.should_not_receive(:update_attributes)
      RedeemWinning.issue_mxit_money_to_users
    end

    it "must work even if error occurs" do
      exception = Exception.new("error")
      @mxit_money_connection.should_receive(:issue_money).and_raise(exception)
      Airbrake.should_receive(:notify_or_ignore).
        with(exception, :parameters => {:redeem_winning => @redeem_winning}, :cgi_data => ENV)
      RedeemWinning.issue_mxit_money_to_users
    end


  end

end
