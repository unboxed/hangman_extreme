class RenameCluePointsToCreditsOnUsers < ActiveRecord::Migration

  def change
    change_table :users do |t|
      t.rename :clue_points, :credits
    end
    change_column_default :users, :credits, 70
  end

end
