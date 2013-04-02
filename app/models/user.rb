class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :clue_points, :prize_points
  attr_accessible :real_name, :mobile_number, as: 'user'
  RANKING_FIELDS = Winner::WINNING_PERIODS.product(Winner::WINNING_REASONS - %w(random)).map{|x,y| "#{x}_#{y}"}

  has_many :games, :order => 'id ASC'
  has_many :winners
  has_many :redeem_winnings

  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider

  scope :top_scorers, lambda{ |field| order("#{field} DESC") }
  scope :mxit, where(provider: 'mxit')
  scope :active_last_hour, lambda{ where('updated_at >= ?',1.hour.ago) }
  scope :random_order, order(connection.instance_values["config"][:adapter].include?("mysql") ? 'RAND()' : 'RANDOM()')

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
    save
  end

  def update_weekly_scores
    self.weekly_rating = calculate_weekly_rating
    self.weekly_precision = calculate_weekly_precision
    save
  end

  def rank(field,user_scope = User)
    user_scope.where("#{field} > ?", send(field)).count + 1
  end

  def utma(update_tracking = false)
    google_tracking.utma(update_tracking)
  end

  def google_tracking
    @google_tracking ||= GoogleTracking.find_or_create_by_user_id(id)
  end

  def send_message(msg)
    User.send_message(msg,[self])
  end

  def registered_on_mxit_money?
    begin
      connection = MxitMoneyApi.connect(ENV['MXIT_MONEY_API_KEY'])
      if connection
        result = connection.user_info(:id => uid)
        result[:is_registered]
      end
    rescue Exception => e
      Rails.logger.error(e.message)
      Airbrake.notify_or_ignore(
        e,
        :parameters    => {:user => self},
        :cgi_data      => ENV
      )
      false
    end
  end

  def not_registered_on_mxit_money?
    !registered_on_mxit_money?
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

  def self.new_day_set_scores!(force_week = false)
    User.update_all(daily_wins: 0, daily_rating: 0, daily_precision: 0, daily_streak: 0, current_daily_streak: 0)
    if Date.current == Date.current.beginning_of_week || force_week
      User.update_all(weekly_wins: 0, weekly_rating: 0, weekly_precision: 0, weekly_streak: 0, current_weekly_streak: 0)
    end
  end

  def self.update_scores!
    user_ids = Game.today.collect{|g|g.user_id}.uniq
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
    "<User id:#{id} name:#{name}>"
  end

  def inspect
    to_s
  end

  def daily_wins_required_for_random
    [Winner.daily_random_games_required - daily_wins,0].max
  end

  def weekly_wins_required_for_random
    [Winner.weekly_random_games_required - weekly_wins,0].max
  end


  private

  def calculate_precision(game_scope, game_count = 10)
    scope = game_scope.completed
    return 0 if scope.count < game_count
    (scope.sum(:completed_attempts_left).to_i * 10) / scope.count
  end

  def calculate_rating(scope)
    scope.inject(0){|sum,game| sum += game.score.to_i }
  end

end
