require 'spec_helper'

describe IssueMxitMoneyToUsers do

  context "issue_mxit_money_to_users" do

    before :each do
      @redeem_winning = stub_model(RedeemWinning, id: 333,
                                   prize_amount: 23,
                                   user_uid: 'm221',
                                   state: 'paid',
                                   cancel!: true)
      RedeemWinning.stub!(:find).and_return(@redeem_winning)
    end

    def issue_money
      IssueMxitMoneyToUsers.new.perform(333)
    end

    it "must find the pending redeem winning" do
      RedeemWinning.should_receive(:find).with(333).and_return(@redeem_winning)
      issue_money
    end

    context "Not Pending" do

      it "must not connect to Mxit Money Api" do
        MxitMoneyApi.should_not_receive(:connect)
        issue_money
      end

    end

    context "Pending" do

      before :each do
        @redeem_winning.state = 'pending'
        MxitMoneyApi.stub(:connect)
      end

      context "unsuccesfull connection" do

        it "must connect to mxit money" do
          lambda{issue_money}.should raise_error('Could not connect to Mxit Api')
        end

      end

      context "Succesfull Connection" do

        before :each do
          @mxit_money_connection = mock("connection",
                                        :user_info => {is_registered: true, msisdn: '0713450987'},
                                        :issue_money => {:m2_reference => "ref1"})
          MxitMoneyApi.stub(:connect).and_return(@mxit_money_connection)
        end

        it "must connect to mxit money" do
          MxitMoneyApi.should_receive(:connect).with(ENV['MXIT_MONEY_API_KEY'])
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
                 :amount_in_cents => 23).and_return(:m2_reference => "test")
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
          lambda{issue_money}.should raise_error('Invalid Result from Mxit Api')
        end

      end

    end

  end

end