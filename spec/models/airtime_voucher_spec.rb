# == Schema Information
#
# Table name: airtime_vouchers
#
#  id                  :integer          not null, primary key
#  redeem_winning_id   :integer
#  _deprecated_user_id :integer
#  freepaid_refno      :string(255)
#  network             :string(255)
#  pin                 :string(255)
#  sellvalue           :float
#  response            :text
#  created_at          :datetime
#  updated_at          :datetime
#  user_account_id     :integer
#

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

    describe "user_account" do
      it "must respond_to user_account" do
        AirtimeVoucher.new.should respond_to(:user_account)
      end

      it "must be able to assign a user_account" do
        airtime_voucher = AirtimeVoucher.new
        airtime_voucher.user_account = create(:user_account)
        airtime_voucher.user_account.should be_kind_of(UserAccount)
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
