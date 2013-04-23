require 'spec_helper'

describe IssueMxitMoneyToUsers do

  context "issue_mxit_money_to_users" do

    before :each do
      @redeem_winning = stub_model(RedeemWinning, id: 333,
                                   prize_amount: 23,
                                   user: stub_model(User, prize_points: 1000,
                                                    uid: 'm221',
                                                    paid!: true),
                                   state: 'pending')
      RedeemWinning.stub!(:find).and_return(@redeem_winning)
      @mxit_money_connection = mock("connection",
                                    :user_info => {is_registered: true, msisdn: '0713450987'},
                                    :issue_money => {:m2_reference => "ref1"})
      MxitMoneyApi.stub(:connect).and_return(@mxit_money_connection)
    end

    def issue_money
      IssueMxitMoneyToUsers.new.perform(333)
    end

    it "must find the pending redeem winning" do
      RedeemWinning.should_receive(:find).with(333).and_return(@redeem_winning)
      issue_money
    end

    it "must connect to mxit money" do
      MxitMoneyApi.should_receive(:connect).with(ENV['MXIT_MONEY_API_KEY']).and_return(@mxit_money_connection)
      issue_money
    end

    it "must check the user_info with uid" do
      @mxit_money_connection.should_receive(:user_info).with(:id => 'm221').and_return({})
      issue_money
    end

    it "must issue money to user" do
      @mxit_money_connection.should_receive(:issue_money).
        with(:phone_number => '0713450987',
             :merchant_reference => "RW333Y#{Time.current.yday}H#{Time.current.hour}",
             :amount_in_cents => 23).and_return({})
      issue_money
    end

    it "must update to paid!" do
      @redeem_winning.should_receive(:paid!)
      @redeem_winning.should_receive(:update_column).with(:mxit_money_reference,"ref1")
      issue_money
    end

    it "wont update to paid! if issue error" do
      @mxit_money_connection.should_receive(:issue_money).and_return({})
      @redeem_winning.should_not_receive(:paid!)
      issue_money
    end

  end

end