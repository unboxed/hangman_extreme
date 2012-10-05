class RenameGameWonColumnsToWinsOnUsers < ActiveRecord::Migration
  def change
    change_table 'users' do |t|
      t.rename :games_won_today, :daily_wins
      t.rename :games_won_this_week, :weekly_wins
      t.rename :games_won_this_month, :monthly_wins
    end
  end
end
