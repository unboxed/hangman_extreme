class RenameWinsToPointsOnUsers < ActiveRecord::Migration
  def up
    change_table 'users' do |t|
      t.rename 'daily_wins', 'daily_points'
      t.rename 'weekly_wins', 'weekly_points'
      t.rename 'monthly_wins', 'monthly_points'
    end
  end

  def down
    change_table 'users' do |t|
      t.rename 'daily_points', 'daily_wins'
      t.rename 'weekly_points', 'weekly_wins'
      t.rename 'monthly_points', 'monthly_wins'
    end
  end
end
