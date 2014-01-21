class AddUserAccountIdToPurchaseTransactions < ActiveRecord::Migration
  def change
    change_table :purchase_transactions do |t|
      t.integer :user_account_id
      t.rename :user_id, :_deprecated_user_id
    end
  end
end
