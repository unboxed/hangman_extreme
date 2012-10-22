class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :clue_points, :prize_points
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
      user.login = auth_hash['info']['login']
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
    calculate_rating(games.today.first(10))
  end

  def calculate_weekly_rating
    calculate_rating(games.this_week.first(35))
  end

  def calculate_monthly_rating
    calculate_rating(games.this_month.first(70))
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

  def update_daily_scores
    self.daily_rating = calculate_daily_rating
    self.daily_precision = calculate_daily_precision
    self.daily_wins = calculate_daily_wins
    save
  end

  def update_weekly_scores
    self.weekly_rating = calculate_weekly_rating
    self.weekly_precision = calculate_weekly_precision
    self.weekly_wins = calculate_weekly_wins
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
    utma = "1.#{id}00145214523.#{google_tracking.initial_visit}.#{google_tracking.previous_session}.#{google_tracking.current_session}.15"
    "__utma=#{utma};+__utmz=1.#{google_tracking.current_session}.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none);"
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
          users.uniq.in_groups_of(100,false).each do |user_group|
            to = user_group.collect(&:uid).join(",")
            mxit_connection.send_message(body: msg, to: to)
          end
        end
      end
    end
  end

  def self.cohort_array
    cohort = []
    end_of_week = Time.current.beginning_of_day - 1.day
    start_of_week = end_of_week - 7.days
    while(Game.where('games.created_at >= ? AND games.created_at <= ?',start_of_week,end_of_week).any?)
      user_scope = User.mxit.where('users.created_at <= ?',end_of_week )
      all_users_count = user_scope.count
      new_active_users = new_competitive_users = 0
      user_scope.where('users.created_at >= ?',start_of_week).joins(:games).
      where("games.created_at >= ? AND games.created_at <= ?",start_of_week,end_of_week).
      count("games.id",group: 'users.id').each do |user_id,count|
        if count > 35
          new_competitive_users += 1
        else
          new_active_users += 1
        end
      end
      active_users = competitive_users = 0
      user_scope.where('users.created_at <= ?',start_of_week).
        joins("LEFT JOIN games ON users.id = games.user_id").
        where("(games.created_at >= ? AND games.created_at <= ?) OR games.created_at IS NULL",start_of_week,end_of_week).
        count("games.id",group: 'users.id').each do |user_id,count|
          if count > 35
            competitive_users += 1
          else
            active_users += 1
          end
      end
      inactive_users = all_users_count - (new_active_users + new_competitive_users + active_users + competitive_users)
      cohort << [end_of_week.strftime("%d-%m"),
                new_active_users,
                new_competitive_users,
                inactive_users,
                active_users,
                competitive_users]
      start_of_week -= 1.day
      end_of_week -= 1.day
    end
    cohort.reverse
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
