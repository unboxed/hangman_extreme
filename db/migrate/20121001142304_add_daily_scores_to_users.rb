class AddDailyScoresToUsers < ActiveRecord::Migration
  def change
    add_column :users, :daily_rating, :integer, :default => 0
    add_column :users, :daily_precision, :integer, :default => 0
    add_column :users, :games_won_today, :integer, :default => 0
    add_index :users, :daily_rating
    add_index :users, :daily_precision
    add_index :users, :games_won_today
  end
end
