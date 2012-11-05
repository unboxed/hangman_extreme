class RenamePointsToScoreOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :daily_points, :daily_score
    rename_column :users, :weekly_points, :weekly_score
  end
end
