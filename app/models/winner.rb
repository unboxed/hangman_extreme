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
    return if where(end_of_period_on: Date.today, period: 'daily').any?
    ['rating','precision','wins'].each do |field|
      create_daily_winners_for_category(field,winnings)
    end
    User.send_message("We have selected our $winners$ for the day, Congratulations to those who have won.")
  end

  def self.create_daily_winners_for_category(field,winnings)
    User.top_scorers("daily_#{field}").each_with_index do |user|
      amount = winnings[user.rank("daily_#{field}") - 1]
      Winner.create!(user_id: user.id,
                     amount: amount,
                     reason: field,
                     end_of_period_on: Date.today,
                     period: 'daily')
      user.send_message("Congratulations, you have won *#{amount} moola* for $daily #{field}$. Please make sure you have entered your details on the $profile$ and you have added the *extremepayout* contact.")
    end
  end


  def daily?
    period == 'daily'
  end

  def self.yesterday_winners_to_s
    yesterday.group_by(&:user).collect{|u,w|[CGI::unescape(u.name),u.real_name,u.uid,w.sum(&:amount)].join(" : ")}.join("\n")
  end

end
