# == Schema Information
#
# Table name: purchase_transactions
#
#  id                  :integer          not null, primary key
#  _deprecated_user_id :integer
#  product_id          :string(255)      not null
#  product_name        :string(255)      not null
#  product_description :text
#  moola_amount        :integer          not null
#  currency_amount     :string(255)      not null
#  ref                 :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  user_account_id     :integer
#

require 'spec_helper'

describe PurchaseTransaction do

  context "Validation" do

    it "must have a product id" do
      PurchaseTransaction.new.should have(1).errors_on(:product_id)
      PurchaseTransaction.new(product_id: 'credits1').should have(0).errors_on(:product_id)
    end

    it "must have a ref" do
      PurchaseTransaction.new.should have(1).errors_on(:ref)
      PurchaseTransaction.new(ref: 'ref').should have(0).errors_on(:ref)
    end

    it "must have a moola_amount" do
      PurchaseTransaction.new.should have(1).errors_on(:moola_amount)
      PurchaseTransaction.new(moola_amount: 1).should have(0).errors_on(:moola_amount)
    end

    it "must have a minimum of 1 moola_amount" do
      PurchaseTransaction.new(moola_amount: 0).should have(1).errors_on(:moola_amount)
      PurchaseTransaction.new(moola_amount: -100).should have(1).errors_on(:moola_amount)
      PurchaseTransaction.new(moola_amount: 100).should have(0).errors_on(:moola_amount)
    end

    it "must have a user_id" do
      PurchaseTransaction.new.should have(1).errors_on(:user_account_id)
      PurchaseTransaction.new(user_account_id: 1).should have(0).errors_on(:user_account_id)
    end

    it "must have a currency_amount" do
      PurchaseTransaction.new.should have(1).errors_on(:currency_amount)
      PurchaseTransaction.new(currency_amount: "1 cent").should have(0).errors_on(:currency_amount)
    end

    it "must have a product_name" do
      PurchaseTransaction.new.should have(1).errors_on(:product_name)
      PurchaseTransaction.new(product_name: '1 credits').should have(0).errors_on(:product_name)
    end

  end

end
