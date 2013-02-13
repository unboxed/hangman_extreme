class AddWeeklyStreakToUsers < ActiveRecord::Migration
  def change
    # add_column :users, :weekly_streak, :integer, :default => 0, :null => false
    rename_column :users, :weekly_score, :weekly_streak
    add_column :users, :current_weekly_streak, :integer, :default => 0, :null => false
  end
end
