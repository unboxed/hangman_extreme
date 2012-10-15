class AddPrizePointsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :prize_points, :integer, default: 0, null: false
  end
end
