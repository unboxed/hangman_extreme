 # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :winner do
    reason "rating"
    amount 1
    end_of_period_on Date.current
    period 'daily'
    user { create(:user, name: "user_#{reason} #{User.count}" )}
  end
end
