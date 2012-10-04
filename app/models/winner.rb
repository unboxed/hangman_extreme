class Winner < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :amount, :reason, :period, :start_of_period_on

  validates :user_id, :amount, :reason, :start_of_period_on, presence: true
  validates :period, inclusion: %w(daily weekly monthly)

  delegate :name, to: :user

  def self.create_daily_winners(winnings)
    return if where(start_of_period_on: Date.today, period: 'daily').any?
    ['daily_rating','daily_precision','games_won_today'].each do |field|
      User.top_scorers(field).each_with_index do |user,index|
        Winner.create!(user_id: user.id,
                       amount: winnings[index],
                       reason: field,
                       start_of_period_on: Date.today,
                       period: 'daily')
      end
    end
  end

  def daily?
    period == 'daily'
  end

end
