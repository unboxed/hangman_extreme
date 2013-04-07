# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :redeem_winning do
    prize_amount 1
    prize_type "mxit_money"
    state "pending"
    user {create(:user, prize_points: 1000)}
  end
end
