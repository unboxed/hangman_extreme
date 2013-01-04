class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :clue_points, :prize_points
  attr_accessible :real_name, :mobile_number, as: 'user'
  RANKING_FIELDS = Winner::WINNING_PERIODS.product(Winner::WINNING_REASONS).map{|x,y| "#{x}_#{y}"}

  has_many :games, :order => 'id ASC'
  has_many :winners
  has_many :redeem_winnings

  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider

  scope :top_scorers, lambda{ |field| order("#{field} DESC").limit(10) }
  scope :mxit, where(provider: 'mxit')

  def self.find_or_create_from_auth_hash(auth_hash)
    auth_hash.stringify_keys!
    logger.debug "Auth Login Attempt with: #{auth_hash.to_s}"
    return nil if auth_hash['uid'].blank? || auth_hash['provider'].blank?
    user = find_or_create_by_uid_and_provider(auth_hash['uid'],auth_hash['provider'])
    if auth_hash['info']
      auth_hash['info'].stringify_keys!
      user.name = auth_hash['info']['name']
      user.login = auth_hash['info']['login']
      user.save
    end
    return user
  end

  def calculate_daily_score
    calculate_games_score(games.today)
  end

  def calculate_weekly_score
    calculate_games_score(games.this_week)
  end

  def calculate_daily_precision
    calculate_precision(games.today)
  end

  def calculate_weekly_precision
    calculate_precision(games.this_week,35)
  end

  def calculate_daily_rating
    calculate_rating(games.today.first(10))
  end

  def calculate_weekly_rating
    calculate_rating(games.this_week.first(35))
  end

  def update_ratings
    update_daily_scores
    update_weekly_scores
  end

  def update_daily_scores
    self.daily_rating = calculate_daily_rating
    self.daily_precision = calculate_daily_precision
    self.daily_score = calculate_daily_score
    save
  end

  def update_weekly_scores
    self.weekly_rating = calculate_weekly_rating
    self.weekly_precision = calculate_weekly_precision
    self.weekly_score = calculate_weekly_score
    save
  end

  def rank(field)
    User.where("#{field} > ?", send(field)).count + 1
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
      mxit_connection = MxitApiWrapper.connect
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

  def self.purge_tracking!
    User.where('updated_at < ?',7.days.ago).each{|u| u.google_tracking.delete }.size
  end

  def self.add_clue_point_to_active_players!
    user_ids = Game.today.collect{|g|g.user_id}.uniq
    User.find(user_ids).each do |user|
      begin
        user.increment!(:clue_points)
      rescue ActiveRecord::StaleObjectError => e
        Rails.logger.error(e.message)
      end
    end
  end

  def self.new_day_set_scores!
    User.update_all(daily_rating: 0, daily_precision: 0, daily_score: 0)
    if Date.current == Date.current.beginning_of_week
      User.update_all(weekly_rating: 0, weekly_precision: 0, weekly_score: 0)
    end
    user_ids = Game.since_yesterday.collect{|g|g.user_id}.uniq
    User.where('id IN (?)',user_ids).each do |user|
      begin
        user.update_daily_scores
        if Date.current == Date.current.beginning_of_week
          user.update_weekly_scores
        end
      rescue Exception => e
        raise if Rails.env.test?
      end
    end
  end

  def self.cohort_array
    cohort = []
    first_day = 49.days.ago
    end_of_week = Time.current.beginning_of_day - 1.day
    start_of_week = end_of_week - 7.days
    while(start_of_week >= first_day)
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
      user_scope.where('users.created_at <= ?',start_of_week).joins(:games).
        where("games.created_at >= ? AND games.created_at <= ?",start_of_week,end_of_week).
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
      start_of_week -= 2.day
      end_of_week -= 2.day
    end
    cohort.reverse
  end

  def self.scoring_fields
    RANKING_FIELDS.clone
  end

  private

  def calculate_games_score(scope)
    scope.all.inject(0) do |acc,game|
      if game.is_won?
        acc += 10
      elsif game.is_lost?
        acc -= 3
      else
        acc -= 20
      end
    end
  end

  def calculate_precision(game_scope, game_count = 10)
    scope = game_scope.completed
    return 0 if scope.count < game_count
    (scope.inject(0){|sum,game| sum += game.attempts_left.to_i } * 10) / scope.count
  end

  def calculate_rating(scope)
    scope.inject(0){|sum,game| sum += game.score.to_i }
  end

end
