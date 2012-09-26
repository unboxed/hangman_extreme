class AddPrecisionsRatingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :weekly_precision, :integer, default: 0
    add_column :users, :monthly_precision, :integer, default: 0
    add_index :users, :weekly_precision
    add_index :users, :monthly_precision
  end
end
