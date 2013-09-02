class AddWinnersCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :winners_count, :integer, :default => 0, :null => false
  end
end
