class AddCluePointsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :clue_points, :integer, default: 2, null: false
  end
end
