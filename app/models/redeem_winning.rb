class RedeemWinning < ActiveRecord::Base
  PRIZE_TYPES = ['clue_points','vodago_airtime','cell_c_airtime','mtn_airtime','mxit_money']
  attr_accessible :prize_amount, :prize_type, :state, :user_id, :mxit_money_reference

  validates :user_id, presence: true
  validates :prize_type, inclusion: PRIZE_TYPES
  validates :state, inclusion: ['pending','paid']
  validates_numericality_of :prize_amount, greater_than: 0

  validate :check_user_prize_points
  after_create :update_user_prize_points

  belongs_to :user
  delegate :prize_points, :login, :mobile_number, :uid, :to => :user, :prefix => true

  scope :pending, where('state = ?','pending')
  scope :pending_mxit_money, where('prize_type = ? AND state = ?','mxit_money','pending')


  def self.pending_winnings_text
    pending.joins(:user).includes(:user).order('prize_type,uid').collect{|rw| [rw.prize_type,rw.id,rw.user_uid,rw.user_login,rw.user_mobile_number,rw.prize_amount].join(" : ")}.join("\n")
  end

  def self.paid!(*ids)
    ids.each do |id|
      find(id).paid!
    end
  end

  def self.cohort_array
    cohort = []
    day = maximum(:created_at).try(:end_of_day)
    return [] unless day
    first_day = 21.days.ago
    while(day >= first_day) do
      scope = where('created_at >= ? AND created_at <= ?',day.beginning_of_day,day)
      values = [day.strftime("%d-%m")]
      PRIZE_TYPES.each do |prize_type|
        values << scope.where(prize_type: prize_type).sum(:prize_amount)
      end
      cohort << values
      day -= 1.day
    end
    cohort.reverse
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

  def paid?
    state == 'paid'
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
