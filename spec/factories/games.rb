# == Schema Information
#
# Table name: games
#
#  id                      :integer          not null, primary key
#  word                    :string(255)
#  choices                 :text
#  user_id                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  completed               :boolean          default(FALSE)
#  score                   :integer
#  clue_revealed           :boolean          default(FALSE), not null
#  completed_attempts_left :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :game do
    word "better"
    choices ""
    user
    factory :won_game do
      choices{ word }
    end
    factory :lost_game do
      choices{ "zzzzzzzzzzzzzzz" }
    end
  end
end
