class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid
  attr_accessible :real_name, :mobile_number, as: 'user'

  has_many :games
  has_many :winners

  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider

  scope :top_scorers, lambda{ |field| order("#{field} DESC").limit(10) }
  scope :mxit, where(provider: 'mxit')

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

  def winners_for_period_and_reason(period,reason)
    winners.period(period).reason(reason)
  end

  def calculate_daily_wins
    calculate_games_won(games.today)
  end

  def calculate_weekly_wins
    calculate_games_won(games.this_week)
  end

  def calculate_monthly_wins
    calculate_games_won(games.this_month)
  end

  def calculate_daily_precision
    calculate_precision(games.today)
  end

  def calculate_weekly_precision
    calculate_precision(games.this_week)
  end

  def calculate_monthly_precision
    calculate_precision(games.this_month)
  end

  def calculate_daily_rating
    calculate_rating(games.today.top(10))
  end

  def calculate_weekly_rating
    calculate_rating(games.this_week.top(20))
  end

  def calculate_monthly_rating
    calculate_rating(games.this_month.top(80))
  end

  def update_ratings
    self.daily_rating = calculate_daily_rating
    self.weekly_rating = calculate_weekly_rating
    self.monthly_rating = calculate_monthly_rating
    self.daily_precision = calculate_daily_precision
    self.weekly_precision = calculate_weekly_precision
    self.monthly_precision = calculate_monthly_precision
    self.daily_wins = calculate_daily_wins
    self.weekly_wins = calculate_weekly_wins
    self.monthly_wins = calculate_monthly_wins
    save
  end

  def rank(field)
    User.where("#{field} > ?", send(field)).count + 1
  end

  def game_count
    games.count
  end

  def utma(update_tracking = false)
    google_tracking.update_tracking if update_tracking
    "1.#{id}00145214523.#{google_tracking.initial_visit}.#{google_tracking.previous_session}.#{google_tracking.current_session}.15"
  end

  def google_tracking
    @google_tracking ||= GoogleTracking.find_or_create_by_user_id(id)
  end

  def send_message(msg)
    User.send_message(msg,[self])
  end

  def self.send_message(msg, users = User.mxit)
    unless users.empty?
      mxit_connection = MxitApi.connect
      if mxit_connection
        if users.kind_of?(ActiveRecord::Relation)
          page = 1
          while((user_group = users.order(:id).page(page).per(100)).any?)
            to = user_group.collect(&:uid).join(",")
            mxit_connection.send_message(body: msg, to: to)
            page += 1
          end
        else
          users.uniq.in_groups_of(20,false).each do |user_group|
            to = user_group.collect(&:uid).join(",")
            mxit_connection.send_message(body: msg, to: to)
          end
        end
      end
    end
  end

  private

  def calculate_games_won(scope)
    scope.completed.all.count{|game| game.is_won?}
  end

  def calculate_precision(game_scope)
    scope = game_scope.completed
    return 0 if scope.count < 10
    (scope.inject(0){|sum,game| sum += game.attempts_left.to_i } * 10) / scope.count
  end

  def calculate_rating(scope)
    scope.inject(0){|sum,game| sum += game.score.to_i }
  end

end
