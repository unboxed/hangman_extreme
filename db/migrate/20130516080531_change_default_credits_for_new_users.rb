class ChangeDefaultCreditsForNewUsers < ActiveRecord::Migration
  def up
    change_column_default :users, :credits, 24
  end

  def down
    change_column_default :users, :credits, 70
  end
end
