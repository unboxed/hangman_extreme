class AddRatingFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :games_won_this_week, :integer, default: 0
    add_column :users, :games_won_this_month, :integer, default: 0
    add_index :users, :games_won_this_week
    add_index :users, :games_won_this_month
  end
end
