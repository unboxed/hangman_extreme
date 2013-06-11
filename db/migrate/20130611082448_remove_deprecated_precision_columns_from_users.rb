class RemoveDeprecatedPrecisionColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_column 'users', '_deprecated_daily_precision'
    remove_column 'users', '_deprecated_weekly_precision'
  end

  def down
    add_column 'users', '_deprecated_weekly_precision', :integer
    add_column 'users', '_deprecated_daily_precision', :integer
  end
end
