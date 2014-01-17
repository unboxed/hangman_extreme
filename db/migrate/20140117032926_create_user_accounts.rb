class CreateUserAccounts < ActiveRecord::Migration
  def change
    create_table :user_accounts do |t|
      t.string :uid, :null => false
      t.string :provider, :null => false
      t.string :real_name
      t.string :mobile_number
      t.string :email
      t.integer :credits, :default => 24
      t.integer :prize_points
      t.integer :lock_version, :default => 0, :null => false
      t.timestamps
    end
  end
end
