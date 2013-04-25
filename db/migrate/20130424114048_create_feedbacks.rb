class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedback do |t|
      t.belongs_to :user
      t.string :subject
      t.text :message
      t.string :support_type, :default => 'suggestion'
      t.timestamps
    end
    add_index :feedback, :user_id
  end
end
