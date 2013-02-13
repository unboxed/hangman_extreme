class AddDailyStreakToUsers < ActiveRecord::Migration
  def change
    # add_column :users, :daily_streak, :integer, :default => 0, :null => false
    rename_column :users, :daily_score, :daily_streak
    add_column :users, :current_daily_streak, :integer, :default => 0, :null => false
  end
end
