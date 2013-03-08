class AddAttemptsLeftToGames < ActiveRecord::Migration
  def change
    add_column :games, :completed_attempts_left, :integer
  end
end
