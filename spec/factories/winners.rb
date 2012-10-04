# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :winner do
    user
    reason "daily_rating"
    amount 1
    start_of_period_on Date.today
    period 'daily'
  end
end
