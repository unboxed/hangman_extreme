class AddRealNameAndMobileNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :real_name, :string
    add_column :users, :mobile_number, :string
  end
end
