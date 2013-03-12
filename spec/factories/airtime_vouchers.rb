# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :airtime_voucher do
    redeem_winning
    freepaid_refno "MyString"
    network "MyString"
    sellvalue 1.5
    response "MyText"
    pin "123123"
  end
end
