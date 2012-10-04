class CreateWinners < ActiveRecord::Migration
  def change
    create_table :winners do |t|
      t.belongs_to :user
      t.string :reason
      t.integer :amount
      t.string :period
      t.date :start_of_period_on
      t.timestamps
    end
    add_index :winners, :user_id
  end
end
