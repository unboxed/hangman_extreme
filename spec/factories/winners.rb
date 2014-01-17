# == Schema Information
#
# Table name: winners
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  reason           :string(255)
#  amount           :integer
#  period           :string(255)
#  end_of_period_on :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

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
