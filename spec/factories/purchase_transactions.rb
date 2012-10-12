# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :purchase_transaction do
    ref {PurchaseTransaction.new.generate_ref}
    product_id PurchaseTransaction.products.keys.first
    product_description "MyText"
  end
end
