class DeprecateAccountFieldsInUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      %w(real_name mobile_number email credits prize_points login).each do |col_name|
        t.rename col_name, "_deprecated_#{col_name}"
      end
    end
  end
end
