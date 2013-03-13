class Winner < ActiveRecord::Base
  WEEKLY_PRIZE_AMOUNTS = [500,500,500,500,500]
  DAILY_PRIZE_AMOUNTS  = [ 70, 70, 70, 70, 70]
  WINNING_PERIODS = ['daily','weekly']
  WINNING_REASONS = ['streak','rating','precision']
  belongs_to :user
  attr_accessible :user_id, :amount, :reason, :period, :end_of_period_on

  validates :user_id, :amount, :reason, :end_of_period_on, presence: true
  validates :period, inclusion: %w(daily weekly)

  scope :period, lambda{ |p| where("period = ?",p) }
  scope :reason, lambda{ |r| where("reason = ?",r) }
  scope :yesterday, lambda{ where(:end_of_period_on => Date.yesterday) }

  delegate :name, to: :user

  after_create :increase_prize_points

  def self.create_daily_winners(winnings = DAILY_PRIZE_AMOUNTS)
    if create_winners('daily',winnings)
    User.send_message("We have selected our $winners$ for the daily prizes, Congratulations to those who have won.",
                      User.mxit.where('updated_at > ?',2.day.ago))
    end
  end

  def self.create_weekly_winners(winnings = WEEKLY_PRIZE_AMOUNTS)
    if create_winners('weekly',winnings)
      User.send_message("We have selected our $winners$ for the weekly prizes, Congratulations to those who have won.",
                         User.mxit.where('updated_at > ?',7.day.ago))
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
    field = "#{options[:period]}_#{options[:score_by]}"
    winners = []
    previous_winners = period(options[:period]).reason(options[:score_by]).order('created_at DESC').limit(options[:winnings].size)
    user_scope = User.where('id NOT IN (?)',previous_winners.map(&:user_id) + [0])
    min_score = user_scope.top_scorers(field).all.last.send(field)
    user_scope.where("#{field} >= ?",min_score).group_by{|u| u.rank(field) }.each do |rank,users|
      prize_total = 0
      users_count = users.size
      users.each_with_index do |user,index|
        prize_total += (options[:winnings][rank - 1 + index]  || 1)
      end
      users.each do |user|
        winners << Winner.create(user_id: user.id,
                              amount: (prize_total.to_f / users_count).round,
                              reason: options[:score_by],
                              end_of_period_on: Date.current,
                              period: options[:period])
      end
    end
    winners.group_by{|w| w.amount }.each do |amount,winners_group|
        User.send_message("Congratulations, you have won *#{amount} prize points* for _#{options[:period]} #{options[:score_by]}_.
                           Check the $redeem$ section to see what you can trade them in for.".squish,winners_group.map{|info| info.user })
    end
  end

  def self.cohort_array
    cohort = []
    first_day = minimum(:created_at).try(:beginning_of_day)
    return [] unless first_day
    day = maximum(:created_at).beginning_of_day
    while(day >= first_day) do
      winner_scope = where('winners.created_at >= ? AND winners.created_at < ?',day,day + 1.day)
      user_ids = winner_scope.collect{|w| w.user_id }.uniq
      win_earlier_user_ids = where('winners.created_at < ?',day).collect{|w| w.user_id }.uniq
      first_time_user_ids = user_ids - win_earlier_user_ids
      user_ids -= first_time_user_ids
      won_yesterday_user_ids =  where('winners.created_at >= ? AND winners.created_at < ?',day - 1.day,day).collect{|w| w.user_id }.uniq
      yesterday_user_ids = user_ids - won_yesterday_user_ids

      cohort << [day.strftime("%d-%m"),
                 user_ids.size - yesterday_user_ids.size,
                 yesterday_user_ids.size,
                 first_time_user_ids.size]

      day -= 1.day
    end
    cohort.reverse
  end

  protected

  def increase_prize_points
    if amount > 0
      begin
        user.increment!(:prize_points,amount)
      rescue
        user.reload
        begin
          user.increment!(:prize_points,amount)
        rescue
          # ignore second time around
        end
      end
    end
  end


end
