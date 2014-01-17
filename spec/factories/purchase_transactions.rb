# == Schema Information
#
# Table name: purchase_transactions
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  product_id          :string(255)      not null
#  product_name        :string(255)      not null
#  product_description :text
#  moola_amount        :integer          not null
#  currency_amount     :string(255)      not null
#  ref                 :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :purchase_transaction do
    ref {PurchaseTransaction.new.generate_ref}
    product_id {PurchaseTransaction.products.keys.first}
    product_description "MyText"
    user
  end
end
