# == Schema Information
#
# Table name: purchase_transactions
#
#  id                  :integer          not null, primary key
#  _deprecated_user_id :integer
#  product_id          :string(255)      not null
#  product_name        :string(255)      not null
#  product_description :text
#  moola_amount        :integer          not null
#  currency_amount     :string(255)      not null
#  ref                 :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  user_account_id     :integer
#

class Deprecated::PurchaseTransaction < ActiveRecord::Base
  self.table_name = 'purchase_transactions'
end
