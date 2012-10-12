require 'spec_helper'

describe PurchaseTransaction do

  context "Validation" do

    it "must have a product id" do
      PurchaseTransaction.new.should have(1).errors_on(:product_id)
      PurchaseTransaction.new(product_id: 'clue1').should have(0).errors_on(:product_id)
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
      PurchaseTransaction.new.should have(1).errors_on(:user_id)
      PurchaseTransaction.new(user_id: 1).should have(0).errors_on(:user_id)
    end

    it "must have a currency_amount" do
      PurchaseTransaction.new.should have(1).errors_on(:currency_amount)
      PurchaseTransaction.new(currency_amount: "1 cent").should have(0).errors_on(:currency_amount)
    end

    it "must have a product_name" do
      PurchaseTransaction.new.should have(1).errors_on(:product_name)
      PurchaseTransaction.new(product_name: '1 clue point').should have(0).errors_on(:product_name)
    end

  end

end
