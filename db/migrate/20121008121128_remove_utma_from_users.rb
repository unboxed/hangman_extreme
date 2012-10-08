class RemoveUtmaFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :utma
  end

  def down
    add_column :users, :utma, :string
  end
end
