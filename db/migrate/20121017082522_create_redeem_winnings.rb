class CreateRedeemWinnings < ActiveRecord::Migration
  def change
    create_table :redeem_winnings do |t|
      t.belongs_to :user
      t.integer :prize_amount
      t.string :prize_type
      t.string :state
      t.timestamps
    end
    add_index :redeem_winnings, :user_id

  end
end
