require 'spec_helper'
require "#{Rails.root}/app/jobs/issue_airtime_to_users.rb"

describe App::Jobs::IssueAirtimeToUsers do

  describe "run" do

    before :each do
      @redeem_winning = create(:redeem_winning, prize_type: 'vodago_airtime', prize_amount: "500")
      stub_mxit_oauth
    end

    context "success" do

      before :all do
        ENV['FREEPAID_USER'] ||= '3547132'
        ENV['FREEPAID_PASS'] ||= 'hellounb0xed'
      end

      before :each do
        VCR.use_cassette('freepaid') do
          App::Jobs::IssueAirtimeToUsers.new.run
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
        @airtime_voucher.pin.should == "158293554197"
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

      before :all do
        ENV['FREEPAID_USER'] ||= '3547132'
        ENV['FREEPAID_PASS'] = nil
      end

      before :each do
        Airbrake.should_receive(:notify_or_ignore).with(kind_of(Exception))
        VCR.use_cassette('freepaid_fail') do
          App::Jobs::IssueAirtimeToUsers.new.run
        end
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

  describe "on_error" do

    it "must send the error to airbrake" do
      Airbrake.should_receive(:notify_or_ignore).with("Error!")
      App::Jobs::IssueAirtimeToUsers.new.on_error("Error!")
    end

  end

end