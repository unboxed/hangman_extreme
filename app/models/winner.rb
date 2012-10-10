class Winner < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :amount, :reason, :period, :start_of_period_on

  validates :user_id, :amount, :reason, :start_of_period_on, presence: true
  validates :period, inclusion: %w(daily weekly monthly)

  scope :period, lambda{ |p| where("period = ?",p) }
  scope :reason, lambda{ |r| where("reason = ?",r) }


  delegate :name, to: :user

  def self.create_daily_winners(winnings)
    return if where(start_of_period_on: Date.today, period: 'daily').any?
    ['rating','precision','wins'].each do |field|
      create_daily_winners_for_category(field,winnings)
    end
  end

  def self.create_daily_winners_for_category(field,winnings)
    User.top_scorers("daily_#{field}").each_with_index do |user|
      amount = winnings[user.rank("daily_#{field}") - 1]
      Winner.create!(user_id: user.id,
                     amount: amount,
                     reason: field,
                     start_of_period_on: Date.today,
                     period: 'daily')
      user.send_message("Congratulation, you have won *#{amount} moola* for $daily #{field}$. Please make sure you have entered your details on the $profile$ page so we can pay you out.")
    end
  end


  def daily?
    period == 'daily'
  end

end
