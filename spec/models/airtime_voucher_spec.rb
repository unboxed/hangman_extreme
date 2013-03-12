require 'spec_helper'

describe AirtimeVoucher do
  context "Validation" do

    it "wont have no freepaid_refno" do
      AirtimeVoucher.new.should have(1).errors_on(:freepaid_refno)
    end

    it "must have a freepaid_refno" do
      AirtimeVoucher.new(freepaid_refno: 'xx').should have(0).errors_on(:freepaid_refno)
    end

    it "wont have no network" do
      AirtimeVoucher.new.should have(1).errors_on(:network)
    end

    it "must have a network" do
      AirtimeVoucher.new(network: 'xx').should have(0).errors_on(:network)
    end

    it "wont have no pin" do
      AirtimeVoucher.new.should have(1).errors_on(:pin)
    end

    it "must have a pin" do
      AirtimeVoucher.new(pin: 'xx').should have(0).errors_on(:pin)
    end

    it "wont have no redeem_winning_id" do
      AirtimeVoucher.new.should have(1).errors_on(:redeem_winning_id)
    end

    it "must have a redeem_winning_id" do
      AirtimeVoucher.new(redeem_winning: create(:redeem_winning)).should have(0).errors_on(:redeem_winning_id)
    end

  end

  context "Associations" do

    describe "redeem_winning" do

       it "must respond_to redeem_winning" do
         AirtimeVoucher.new.should respond_to(:redeem_winning)
       end

       it "must be able to assign a redeem_winning" do
         airtime_voucher = AirtimeVoucher.new
         airtime_voucher.redeem_winning = create(:redeem_winning)
         airtime_voucher.redeem_winning.should be_kind_of(RedeemWinning)
       end

    end

    describe "user" do

      it "must respond_to user" do
        AirtimeVoucher.new.should respond_to(:user)
      end

      it "must be able to assign a user" do
        airtime_voucher = AirtimeVoucher.new
        airtime_voucher.user = create(:user)
        airtime_voucher.user.should be_kind_of(User)
      end

    end

  end

  describe "response" do

    it "must serialize data to the database" do
      create(:airtime_voucher, response: {body: "Hello"})
      AirtimeVoucher.last.response.should == {body: "Hello"}
    end

  end

  end
