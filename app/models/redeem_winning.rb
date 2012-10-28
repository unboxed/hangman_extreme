class RedeemWinning < ActiveRecord::Base
  attr_accessible :prize_amount, :prize_type, :state, :user_id

  validates :user_id, presence: true
  validates :prize_type, inclusion: ['clue_points','moola','vodago_airtime']
  validates :state, inclusion: ['pending','paid']
  validates_numericality_of :prize_amount, greater_than: 0

  validate :check_user_prize_points
  after_create :update_user_prize_points

  belongs_to :user

  protected

  def check_user_prize_points
    if user && prize_amount && user.prize_points < prize_amount
      errors.add(:user_id,"does not have enough prize points")
    end
  end

  def update_user_prize_points
    user.decrement!(:prize_points,prize_amount)
    if prize_type == 'clue_points'
      update_column(:state, 'paid')
      user.increment!(:clue_points,prize_amount)
    end
  end

end
