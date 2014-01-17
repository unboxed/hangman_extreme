# == Schema Information
#
# Table name: redeem_winnings
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  prize_amount         :integer
#  prize_type           :string(255)
#  state                :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  mxit_money_reference :text
#

class RedeemWinning < ActiveRecord::Base
  PRIZE_TYPES = %W(clue_points vodago_airtime cell_c_airtime mtn_airtime mxit_money virgin_airtime heita_airtime).freeze

  validates :user_id, presence: true
  validates :prize_type, inclusion: PRIZE_TYPES
  validates :state, inclusion: ['pending','cancelled','paid']
  validates_numericality_of :prize_amount, greater_than: 0

  validate :check_user_prize_points
  after_create :update_user_prize_points
  after_commit :issue_mxit_money, :issue_airtime, :on => :create

  belongs_to :user
  delegate :prize_points, :login, :mobile_number, :uid, :to => :user, :prefix => true

  scope :pending, -> { where('state = ?','pending') }
  scope :pending_mxit_money, -> { where('prize_type = ? AND state = ?','mxit_money','pending') }
  scope :pending_airtime, -> { where('prize_type LIKE ? AND state = ?','%airtime','pending') }
  scope :last_day, -> { where('created_at >= ?',1.day.ago) }

  def self.paid!(*ids)
    ids.each do |id|
      find(id).paid!
    end
  end

  def paid!
    update_column(:state, 'paid')
  end

  def cancel!
    if pending?
      self.class.transaction do
        update_column(:state, 'cancelled')
        user.increment!(:prize_points,prize_amount)
      end
    end
  end

  def paid?
    state == 'paid'
  end

  def pending?
    state == 'pending'
  end

  def mxit_money?
    prize_type == 'mxit_money'
  end

  def airtime?
    prize_type.include?("airtime")
  end

  protected

  def check_user_prize_points
    if user && prize_amount && user_prize_points < prize_amount
      errors.add(:user_id,"does not have enough prize points")
    end
  end

  def update_user_prize_points
    user.decrement!(:prize_points,prize_amount)
  end

  def issue_mxit_money
    IssueMxitMoneyToUsers.perform_async(self.id) if mxit_money?
  end

  def issue_airtime
    IssueAirtimeToUsers.perform_async(self.id) if airtime?
  end

end
