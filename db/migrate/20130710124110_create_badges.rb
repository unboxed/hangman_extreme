class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.string :name
      t.belongs_to :user

      t.timestamps
    end
    add_index :badges, :user_id
  end
end
