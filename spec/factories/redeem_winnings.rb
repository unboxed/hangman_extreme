# == Schema Information
#
# Table name: redeem_winnings
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  prize_amount         :integer
#  prize_type           :string(255)
#  state                :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  mxit_money_reference :text
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :redeem_winning do
    prize_amount 1
    prize_type "mxit_money"
    state "pending"
    user {create(:user, prize_points: 1000)}
  end
end
