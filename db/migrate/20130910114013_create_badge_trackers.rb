class CreateBadgeTrackers < ActiveRecord::Migration
  def change
    create_table :badge_trackers do |t|
      t.integer :user_id
      t.integer :clues_revealed, default: 0

      t.timestamps
    end
  end
end
