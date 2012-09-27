class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :weekly_rating, :games_won_this_week, :games_won_this_month,
                  :monthly_rating, :yearly_rating, :weekly_precision, :monthly_precision

  has_many :games

  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider

  scope :top_this_week, lambda{ |amount| order('weekly_rating DESC').limit(amount) }
  scope :top_this_month, lambda{ |amount| order('monthly_rating DESC').limit(amount) }

  def self.find_or_create_from_auth_hash(auth_hash)
    auth_hash.stringify_keys!
    logger.debug "Auth Login Attempt with: #{auth_hash.to_s}"
    return nil if auth_hash['uid'].blank? || auth_hash['provider'].blank?
    user = find_or_initialize_by_uid_and_provider(auth_hash['uid'],auth_hash['provider'])
    if auth_hash['info']
      auth_hash['info'].stringify_keys!
      user.name = auth_hash['info']['name']
      user.save!
    end
    return user
  end

  def calculate_games_won_this_week
    games.this_week.completed.all.count{|game| game.is_won?}
  end

  def calculate_games_won_this_month
    games.this_month.completed.all.count{|game| game.is_won?}
  end

  def calculate_weekly_precision
    scope = games.this_week.completed
    return 0 if scope.count < 10
    (scope.inject(0){|sum,game| sum += game.attempts_left.to_i } * 10) / scope.count
  end

  def calculate_monthly_precision
    scope = games.this_month.completed
    return 0 if scope.count < 40
    (scope.inject(0){|sum,game| sum += game.attempts_left.to_i } * 10) / scope.count
  end


  def calculate_weekly_rating
    games.this_week.top(20).inject(0){|sum,game| sum += game.score.to_i }
  end

  def calculate_monthly_rating
    games.this_month.top(80).inject(0){|sum,game| sum += game.score.to_i }
  end

  def calculate_yearly_rating
    games.this_year.top(160).inject(0){|sum,game| sum += game.score.to_i }
  end

  def update_ratings
    update_attributes(weekly_rating: calculate_weekly_rating,
                      monthly_rating: calculate_monthly_rating,
                      weekly_precision: calculate_weekly_precision,
                      monthly_precision: calculate_monthly_precision,
                      games_won_this_week: calculate_games_won_this_week,
                      games_won_this_month: calculate_games_won_this_month)
  end

  def rank(field)
    User.where("#{field} > ?", send(field)).count + 1
  end

  def game_count
    games.count
  end

end
