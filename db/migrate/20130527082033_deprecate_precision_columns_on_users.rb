class DeprecatePrecisionColumnsOnUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :daily_precision, :_deprecated_daily_precision
      t.rename :weekly_precision, :_deprecated_weekly_precision
    end
  end
end
