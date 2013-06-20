class AddShowHangmanToUser < ActiveRecord::Migration
  def change
    add_column :users, :show_hangman, :boolean, default: true
  end
end
