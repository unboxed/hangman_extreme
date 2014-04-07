# == Schema Information
#
# Table name: winners
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  reason           :string(255)
#  amount           :integer
#  period           :string(255)
#  end_of_period_on :date
#  created_at       :datetime
#  updated_at       :datetime
#

class Winner < ActiveRecord::Base
  WEEKLY_PRIZE_AMOUNTS = [330,330,330,330,330]
  DAILY_PRIZE_AMOUNTS  = [ 16, 16, 16, 16, 16]
  WINNING_PERIODS = %w(daily weekly)
  WINNING_REASONS = %w(streak rating random)
  belongs_to :user, counter_cache: true

  validates :user_id, :amount, :reason, :end_of_period_on, presence: true
  validates :period, inclusion: %w(daily weekly)

  scope :period, lambda{ |p| where('period = ?',p) }
  scope :reason, lambda{ |r| where('reason = ?',r) }
  scope :yesterday, -> { where(:end_of_period_on => Date.yesterday) }
  scope :last_week, -> { where(:end_of_period_on => Date.current.beginning_of_week.yesterday) }

  delegate :name, to: :user

  after_create :increase_prize_points

  def self.winning_periods
    WINNING_PERIODS
  end

  def self.winning_reasons
    WINNING_REASONS
  end

  def self.winning_ranking_reasons
    WINNING_REASONS - %w(random)
  end

  def self.daily_random_games_required
    5
  end

  def self.weekly_random_games_required
    15
  end

  def self.create_daily_winners(winnings = DAILY_PRIZE_AMOUNTS)
    if create_winners('daily',winnings)
      UserSendMessage.send('We have selected our $winners$ for the daily prizes, Congratulations to those who have won.',
                           User.mxit.where('updated_at > ?',2.day.ago))
    end
  end

  def self.create_weekly_winners(winnings = WEEKLY_PRIZE_AMOUNTS)
    if create_winners('weekly',winnings)
      UserSendMessage.send('We have selected our $winners$ for the weekly prizes, Congratulations to those who have won.',
                           User.mxit.where('updated_at > ?',14.day.ago))
    end
  end

  def self.create_winners(period, winnings)
    return false if where(end_of_period_on: Date.current, period: period).any? #don't create winners twice
    WINNING_REASONS.each do |score_by|
      create_winners_for_category(score_by: score_by, winnings: winnings, period: period)
    end
    true
  end

  def self.create_winners_for_category(options)
    options = HashWithIndifferentAccess.new(options)
    winners = []
    select_winners(options).each do |rank,users|
      prize_total = 0
      users.each_with_index do |user,index|
        prize_total += (options[:winnings][rank - 1 + index] || 1)
      end
      users.each do |user|
        winners << Winner.create(user_id: user.id,
                              amount: (prize_total.to_f / users.size).round,
                              reason: options[:score_by],
                              end_of_period_on: Date.current,
                              period: options[:period])
      end
    end
    winners.group_by{|w| w.amount }.each do |amount,winners_group|
      UserSendMessage.send("Congratulations, you have won *#{amount} prize points* for _#{options[:period]} #{options[:score_by]}_.
                           Check the $redeem$ section to see what you can trade them in for.".squish,winners_group.map{|info| info.user })
    end
  end

  protected

  def increase_prize_points
    IncrementPrizePoints.perform_async(id)
  end

  def self.select_winners(options)
    if options[:score_by] == 'random'
      select_random_winners(options)
    else
      field = "#{options[:period]}_#{options[:score_by]}"
      previous_winners = period(options[:period]).reason(options[:score_by]).order('created_at DESC').limit(options[:winnings].size)
      user_scope = User.where('id NOT IN (?)',previous_winners.map(&:user_id) + [0])
      min_score = user_scope.top_scorers(field).offset(options[:winnings].size - 1).first.send(field)
      user_scope.where("#{field} >= ?",min_score).group_by{|u| u.rank(field,user_scope) }
    end
  end

  def self.select_random_winners(options)
    winners = {}
    winners_left = options[:winnings].size
    pos = 1
    wins_required = options[:period] == 'daily' ? daily_random_games_required : weekly_random_games_required
    previous_winners = period(options[:period]).reason(options[:score_by]).order('created_at DESC').limit(options[:winnings].size)
    user_scope = User.where('id NOT IN (?)',previous_winners.map(&:user_id) + [0]).where("users.#{options[:period]}_wins >= ?",wins_required).random_order
    other_winners = winning_ranking_reasons.collect{|r| period(options[:period]).reason(r).order('created_at DESC').limit(options[:winnings].size).to_a }.flatten
    #  prefer players who have not won in another category
    second_random_winner_users = user_scope.where('users.id NOT IN (?)',other_winners.map(&:user_id)).limit(winners_left)
    if second_random_winner_users.any?
      winners[pos] = second_random_winner_users
      winners_left -= second_random_winner_users.size
      user_scope = user_scope.where('users.id NOT IN (?)',second_random_winner_users.map(&:id))
      pos += 1
    end
    winners[pos] = user_scope.limit(winners_left) if winners_left > 0
    winners
  end
end
