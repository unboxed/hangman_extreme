class AddIndexOnUpdatedAtForUsers < ActiveRecord::Migration

  def change
    add_index :users, :updated_at
    add_index :users, :created_at
  end

end
