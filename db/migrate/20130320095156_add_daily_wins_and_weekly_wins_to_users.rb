class AddDailyWinsAndWeeklyWinsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :daily_wins, :integer, :default => 0, :null => false
    add_column :users, :weekly_wins, :integer, :default => 0, :null => false
  end
end
