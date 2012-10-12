class CreateAddClueRevealedToGames < ActiveRecord::Migration
  def change
    change_table :games do |t|
      t.boolean :clue_revealed, default: false, null: false
    end
  end
end
