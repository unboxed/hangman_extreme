# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :redeem_winning do
    prize_amount 1
    prize_type "clue_points"
    state "pending"
    user
  end
end
