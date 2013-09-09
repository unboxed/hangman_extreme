require 'spec_helper'
require 'support/requests_mxit_api_helpers'
require 'support/vcr_helper'

describe IssueAirtimeToUsers do

  describe "perform" do

    before :each do
      @redeem_winning = create(:redeem_winning, prize_type: 'vodago_airtime', prize_amount: "500")
      stub_mxit_oauth
    end

    context "success" do

      before :each do
        VCR.use_cassette("issue_airtime_to_users",
                         :record => :once,
                         :erb => true) do
          IssueAirtimeToUsers.new.perform(@redeem_winning.id)
        end
        @airtime_voucher = AirtimeVoucher.last
      end

      it "must run create a voucher" do
        @airtime_voucher.should_not be_nil
      end

      it "must set the freepaid_refno" do
        @airtime_voucher.freepaid_refno.should include("RW#{@redeem_winning.id}")
      end

      it "must set the network" do
        @airtime_voucher.network.should == "vodacom"
      end

      it "must set the pin" do
        @airtime_voucher.pin.should match(/\A[0-9]{11,13}\z/)
      end

      it "must set redeem_winning" do
        @airtime_voucher.redeem_winning.should == @redeem_winning
      end

      it "must set user" do
        @airtime_voucher.user.should == @redeem_winning.user
      end

      it "must change the redeem winning to paid" do
        @redeem_winning.reload
        @redeem_winning.should be_paid
      end

    end

    context "failure" do

      before :each do
        @old_pass, ENV['FREEPAID_PASS'] = ENV['FREEPAID_PASS'], nil
        VCR.use_cassette("issue_airtime_to_users_failure",
                        :record => :once,
                        :erb => true,
                        :match_requests_on => [:uri,:method]) do
          lambda do
            IssueAirtimeToUsers.new.perform(@redeem_winning.id)
          end.should raise_error
        end
        ENV['FREEPAID_PASS'] = @old_pass
        @airtime_voucher = AirtimeVoucher.last
      end

      it "must run create a voucher" do
        @airtime_voucher.should be_nil
      end

      it "wont change the redeem winning to paid" do
        @redeem_winning.reload
        @redeem_winning.should_not be_paid
      end

    end

  end

end
