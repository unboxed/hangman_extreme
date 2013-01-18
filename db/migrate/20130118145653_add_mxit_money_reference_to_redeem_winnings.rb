class AddMxitMoneyReferenceToRedeemWinnings < ActiveRecord::Migration
  def change
    add_column :redeem_winnings, :mxit_money_reference, :text
  end
end
