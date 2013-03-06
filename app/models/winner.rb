class Winner < ActiveRecord::Base
  WEEKLY_PRIZE_AMOUNTS = [400,200,125,75,75,50,50,50,50,50]
  DAILY_PRIZE_AMOUNTS = [40,20,12,5,5,5,5,5,5,5]
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

  def self.create_daily_winners(winnings = DAILY_PRIZE_AMOUNTS)
    create_winners('daily',winnings)
  end

  def self.create_weekly_winners(winnings = WEEKLY_PRIZE_AMOUNTS)
    create_winners('weekly',winnings)
  end

  def self.create_winners(period, winnings)
    return if where(end_of_period_on: Date.current, period: period).any?
    WINNING_REASONS.each do |score_by|
      create_winners_for_category(score_by: score_by, winnings: winnings, period: period)
    end
    User.send_message("We have selected our $winners$ for the #{period} prizes, Congratulations to those who have won.",
                      User.mxit.where('updated_at > ?',2.day.ago))
  end

  def self.create_winners_for_category(options)
    options = HashWithIndifferentAccess.new(options)
    field = "#{options[:period]}_#{options[:score_by]}"
    winners = []
    User.top_scorers(field).group_by{|u| u.rank(field) }.each do |rank,users|
      prize_total = 0
      users_count = users.size
      users.each_with_index do |user,index|
        prize_total += (options[:winnings][rank - 1 + index]  || options[:winnings].last)
      end
      users.each do |user|
        winners << Winner.create(user_id: user.id,
                              amount: (prize_total.to_f / users_count).round,
                              reason: options[:score_by],
                              end_of_period_on: Date.current,
                              period: options[:period])
      end
    end
    winners.collect{|w|[w.user,w.amount]}.each do |user,amount|
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
        user.send_message("Congratulations, you have won *#{amount} prize points* for _#{options[:period]} #{options[:score_by]}_.
                           Check the $redeem$ section to see what you can trade them in for.".squish)
      end
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


end
