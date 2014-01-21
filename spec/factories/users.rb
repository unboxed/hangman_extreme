# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  name                      :text
#  uid                       :string(255)
#  provider                  :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  weekly_rating             :integer          default(0)
#  yearly_rating             :integer          default(0)
#  weekly_streak             :integer          default(0)
#  daily_rating              :integer          default(0)
#  daily_streak              :integer          default(0)
#  _deprecated_real_name     :string(255)
#  _deprecated_mobile_number :string(255)
#  _deprecated_email         :string(255)
#  _deprecated_credits       :integer          default(24), not null
#  _deprecated_prize_points  :integer          default(0), not null
#  _deprecated_login         :string(255)
#  lock_version              :integer          default(0), not null
#  current_daily_streak      :integer          default(0), not null
#  current_weekly_streak     :integer          default(0), not null
#  daily_wins                :integer          default(0), not null
#  weekly_wins               :integer          default(0), not null
#  show_hangman              :boolean          default(TRUE)
#  winners_count             :integer          default(0), not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "User #{n}" }
    sequence(:uid) {|n| "uid#{n}" }
    provider "mxit"
    show_hangman true
    credits 100
  end
end
