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

class Game < ActiveRecord::Base
  ATTEMPTS = 10
  belongs_to :user

  validates :word, :user_id, presence: true

  after_validation do |record|
    record.completed = record.done?
    if record.completed?
      set_score
      self.completed_attempts_left = attempts_left
    end
  end

  after_save :update_user_score

  scope :active_first, -> { order('completed ASC, created_at DESC').where('completed IS NOT NULL') }
  scope :completed, -> { where('completed = ?', true) }
  scope :incompleted, -> { where('completed = ?', false) }

  scope :today, -> { where('created_at >= ?',Time.current.beginning_of_day) }
  scope :since_yesterday, -> { where('created_at >= ?',Time.current.beginning_of_day - 1.day) }

  scope :last_hour, -> { where('created_at >= ?',1.hour.ago) }
  scope :this_week, -> { where('created_at >= ?',Time.current.beginning_of_week) }
  scope :this_month, -> { where('created_at >= ?',Time.current.beginning_of_month) }
  scope :this_year, -> { where('created_at >= ?',Time.current.beginning_of_year) }
  scope :top, lambda{ |amount| order('score DESC').limit(amount) }

  def select_random_word
    self.word = Dictionary.random_value
  end

  def add_choice(letter)
    self.choices ||= ""
    return if is_lost? || letter.to_s.size > 1
    letter.downcase!
    self.choices += letter if letter =~ /\p{Lower}/
  end

  def reveal_clue
    if user.credits > 0 && !clue_revealed?
      Game.transaction do
        user.decrement!(:credits)
        toggle!(:clue_revealed)
      end
    end
  end

  def attempts_left
    Game::ATTEMPTS - attempts
  end

  def attempts
    (choice_letters - word_letters).size
  end

  def has_attempts_left?
    attempts_left > 0
  end

  def hangman_text
    return word if done?
    text = word
    word_letters.each{|letter| text.gsub!(letter,"_") unless choices.to_s.include?(letter)}
    text
  end

  def done?
    is_lost? || is_won?
  end

  def is_won?
    (word_letters - choice_letters).empty?
  end

  def is_lost?
    !has_attempts_left?
  end

  def correct_choices
    word_letters & choice_letters
  end

  def possible_last_guess?
    (word_letters - choice_letters).uniq.size == 1
  end

  def time_score
    return 0 unless created_at
    [10 - ((Time.current - created_at).to_i / 10),0].max
  end

  def self.purge_old!
    Game.where('created_at < ?',20.weeks.ago).delete_all
  end

  protected

  def word_letters
    word.to_s.split("")
  end

  def choice_letters
    choices.to_s.split("")
  end


  def set_score
    self.score ||= correct_choices.size + attempts_left + time_score
  end

  def update_user_score
    if completed?
      if is_won?
        user.increment_streak
        user.increment_wins
      else
        user.reset_streak
      end
      user.update_ratings
    end
  end


end
