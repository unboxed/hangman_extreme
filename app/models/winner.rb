class Winner < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :amount, :reason, :period, :end_of_period_on

  validates :user_id, :amount, :reason, :end_of_period_on, presence: true
  validates :period, inclusion: %w(daily weekly monthly)

  scope :period, lambda{ |p| where("period = ?",p) }
  scope :reason, lambda{ |r| where("reason = ?",r) }
  scope :yesterday, lambda{ where(:end_of_period_on => Date.yesterday) }


  delegate :name, to: :user

  def self.create_daily_winners(winnings)
    create_winners('daily',winnings)
  end

  def self.create_weekly_winners(winnings)
    create_winners('weekly',winnings)
  end

  def self.create_monthly_winners(winnings)
    create_winners('monthly',winnings)
  end

  def self.create_winners(period, winnings)
    return if where(end_of_period_on: Date.today, period: period).any?
    ['rating','precision','wins'].each do |score_by|
      create_winners_for_category(score_by: score_by, winnings: winnings, period: period)
    end
    User.send_message("We have selected our $winners$ for the #{period} prizes, Congratulations to those who have won.")
  end

  def self.create_winners_for_category(options)
    options = HashWithIndifferentAccess.new(options)
    field = "#{options[:period]}_#{options[:score_by]}"
    User.top_scorers(field).each_with_index do |user|
      amount = options[:winnings][user.rank(field) - 1]
      Winner.create!(user_id: user.id,
                     amount: amount,
                     reason: options[:score_by],
                     end_of_period_on: Date.today,
                     period: options[:period])
      if amount > 0
        user.send_message("Congratulations, you have won *#{amount} moola* for $#{options[:period]} #{options[:score_by]}$.
                           Please make sure you have entered your details on $profile$ and
                           that you have added the *extremepayout* contact to receive your moola winnings.")
      end
    end
  end

  def self.yesterday_winners_to_s
    yesterday.group_by(&:user).collect{|u,w|[CGI::unescape(u.name),u.real_name,u.uid,w.sum(&:amount)].join(" : ")}.join("\n")
  end

end
