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

require 'mxit_api'

class User < ActiveRecord::Base
  RANKING_FIELDS = Winner::WINNING_PERIODS.product(Winner::WINNING_REASONS - %w(random)).map{|x,y| "#{x}_#{y}"}

  has_many :games, -> { order('id ASC') }
  has_many :winners
  has_many :badges

  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider

  scope :top_scorers, lambda{ |field| order("#{field} DESC") }
  scope :mxit, -> { where(provider: 'mxit') }
  scope :non_mxit, -> { where('provider <> ?','mxit') }
  scope :active_last_hour, -> { where('updated_at >= ?',1.hour.ago) }
  scope :active, -> { where('updated_at >= ?',7.days.ago) }
  scope :last_day, -> { where('created_at >= ?',1.day.ago) }
  scope :random_order, -> { order(connection.instance_values['config'][:adapter].include?('mysql') ? 'RAND()' : 'RANDOM()') }

  delegate :credits, to: :account, prefix: true

  def account
    @account ||=
      UserAccount.find_or_create_with({uid: uid,provider: provider},
                                       real_name: _deprecated_real_name,
                                       mobile_number: _deprecated_mobile_number,
                                       email: _deprecated_email,
                                       credits: _deprecated_credits,
                                       mxit_login: _deprecated_login,
                                       prize_points: _deprecated_prize_points)
  end

  def self.find_or_create_from_auth_hash(auth_hash)
    auth_hash.stringify_keys!
    return nil if auth_hash['uid'].blank? || auth_hash['provider'].blank?
    user = find_by(uid: auth_hash['uid'],provider: auth_hash['provider'])
    unless user
      user = find_or_create_by(uid: auth_hash['uid'],provider: auth_hash['provider'])
      user.set_user_info(auth_hash['info'])
    end
    return user
  end
  def self.find_mxit_user(i)
    mxit.find_by_uid(i)
  end

  def set_user_info(info)
    if info
      info.stringify_keys!
      self.name = info['name']
      save
      account.update_attributes(:mxit_login => info['login'])
      account.update_attributes(:email => info['email']) if account.email.blank?
    end
  end

  def has_five_game_clues_in_sequence
    clues_in_sequence = 0
    games.order(:created_at).each do |game|
      if game.clue_revealed
        clues_in_sequence += 1
      else
        clues_in_sequence = 0
      end
      if clues_in_sequence == 5
        return true 
      end 
    end 
    false 
  end 

  def has_ten_games_in_sequence
    games_in_sequence = 0
    games.order(:created_at).each do |game|
      if game.clue_revealed
        games_in_sequence = 0
      else 
        games_in_sequence += 1
      end 
      if games_in_sequence == 10
        return true
      end 
    end 
    false 
  end 

  def calculate_daily_rating
    calculate_rating(games.today.first(12))
  end

  def calculate_weekly_rating
    calculate_rating(games.this_week.first(75))
  end

  def update_ratings
    update_daily_scores
    update_weekly_scores
  end

  def update_daily_scores
    self.daily_rating = calculate_daily_rating
    save
  end

  def update_weekly_scores
    self.weekly_rating = calculate_weekly_rating
    save
  end

  def rank(field,user_scope = User)
    user_scope.where("#{field} > ?", send(field)).count + 1
  end

  def self.purge_tracking!
    User.where('updated_at < ?',20.days.ago).each{|u| u.google_tracking.delete }.size
  end

  def self.new_day_set_scores!(force_week = false)
    User.update_all(daily_wins: 0, daily_rating: 0, daily_streak: 0, current_daily_streak: 0)
    if Date.current == Date.current.beginning_of_week || force_week
      User.update_all(weekly_wins: 0, weekly_rating: 0, weekly_streak: 0, current_weekly_streak: 0)
    end
  end

  def self.scoring_fields
    RANKING_FIELDS.clone
  end

  def increment_streak
    increment(:current_daily_streak)
    self.daily_streak = current_daily_streak if (current_daily_streak > daily_streak)
    increment(:current_weekly_streak)
    self.weekly_streak = current_weekly_streak if (current_weekly_streak > weekly_streak)
  end

  def increment_wins
    increment(:daily_wins)
    increment(:weekly_wins)
  end
  
  def current_game
    games.incompleted.active_first.today.first
  end

  def reset_streak
    self.current_daily_streak = 0
    self.current_weekly_streak = 0
  end

  def to_s
    "<User id:#{id} uid:#{uid} provider:#{provider}>"
  end

  def daily_wins_required_for_random
    [Winner.daily_random_games_required - daily_wins,0].max
  end

  def weekly_wins_required_for_random
    [Winner.weekly_random_games_required - weekly_wins,0].max
  end

  def mxit?
    provider == 'mxit'
  end

  def guest?
    provider == 'guest'
  end

  private

  def calculate_rating(scope)
    scope.inject(0){|sum,game| sum + game.score.to_i }
  end

end
