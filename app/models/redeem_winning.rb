class RedeemWinning < ActiveRecord::Base
  PRIZE_TYPES = %W(clue_points vodago_airtime cell_c_airtime mtn_airtime mxit_money virgin_airtime heita_airtime).freeze
  attr_accessible :prize_amount, :prize_type, :state, :user_id, :mxit_money_reference

  validates :user_id, presence: true
  validates :prize_type, inclusion: PRIZE_TYPES
  validates :state, inclusion: ['pending','cancelled','paid']
  validates_numericality_of :prize_amount, greater_than: 0

  validate :check_user_prize_points
  after_create :update_user_prize_points

  belongs_to :user
  delegate :prize_points, :login, :mobile_number, :uid, :to => :user, :prefix => true

  scope :pending, where('state = ?','pending')
  scope :pending_mxit_money, where('prize_type = ? AND state = ?','mxit_money','pending')
  scope :pending_airtime, where('prize_type LIKE ? AND state = ?','%airtime','pending')
  scope :last_day, lambda{ where('created_at >= ?',1.day.ago) }

  def self.pending_winnings_text
    pending.joins(:user).includes(:user).order('prize_type,uid').collect{|rw| [rw.prize_type,rw.id,rw.user_uid,rw.user_login,rw.user_mobile_number,rw.prize_amount].join(" : ")}.join("\n")
  end

  def self.paid!(*ids)
    ids.each do |id|
      find(id).paid!
    end
  end

  def self.issue_mxit_money_to_users
    connection = MxitMoneyApi.connect(ENV['MXIT_MONEY_API_KEY'])
    if connection
      pending_mxit_money.each do |winning|
        begin
          result = connection.user_info(:id => winning.user_uid)
          if result[:is_registered]
            result = connection.issue_money(:phone_number => result[:msisdn],
                                            :merchant_reference => "RW#{winning.id}Y#{Time.current.yday}H#{Time.current.hour}",
                                            :amount_in_cents => winning.prize_amount)
            if result[:m2_reference]
              winning.update_column(:state,'paid')
              winning.update_column(:mxit_money_reference,result[:m2_reference])
            else
              Airbrake.notify_or_ignore(
                Exception.new("Mxit Money Payout failed"),
                :parameters    => result,
                :cgi_data      => ENV
              )
              Settings.mxit_money_disabled_until = 2.hours.from_now
            end
          end
        rescue Exception => e
          Airbrake.notify_or_ignore(
            e,
            :parameters    => {:redeem_winning => winning},
            :cgi_data      => ENV
          )
        end
      end
    end
  end

  def paid!
    update_column(:state, 'paid')
  end

  def cancel!
    if pending?
      update_column(:state, 'cancelled')
      user.increment!(:prize_points,prize_amount)
    end
  end

  def paid?
    state == 'paid'
  end

  def pending?
    state == 'pending'
  end

  protected

  def check_user_prize_points
    if user && prize_amount && user_prize_points < prize_amount
      errors.add(:user_id,"does not have enough prize points")
    end
  end

  def update_user_prize_points
    user.decrement!(:prize_points,prize_amount)
    if prize_type == 'clue_points'
      paid!
      user.increment!(:clue_points,prize_amount)
    end
  end

end
