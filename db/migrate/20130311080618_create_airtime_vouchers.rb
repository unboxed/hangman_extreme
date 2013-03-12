class CreateAirtimeVouchers < ActiveRecord::Migration
  def change
    create_table :airtime_vouchers do |t|
      t.belongs_to :redeem_winning
      t.belongs_to :user
      t.string :freepaid_refno
      t.string :network
      t.string :pin
      t.float :sellvalue
      t.text :response
      t.timestamps
    end
    add_index :airtime_vouchers, :redeem_winning_id
    add_index :airtime_vouchers, :user_id
    add_index :airtime_vouchers, :created_at
    add_index :airtime_vouchers, :updated_at
  end
end
