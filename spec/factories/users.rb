# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name "Grant"
    sequence(:uid) {|n| "uid#{n}" }
    provider "mxit"
  end
end