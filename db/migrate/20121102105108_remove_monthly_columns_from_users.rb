class RemoveMonthlyColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :monthly_points
    remove_column :users, :monthly_rating
    remove_column :users, :monthly_precision
  end

  def down
    add_column :users, :monthly_points, :integer, default: 0
    add_column :users, :monthly_rating, :integer, default: 0
    add_column :users, :monthly_precision, :integer, default: 0
  end

end
