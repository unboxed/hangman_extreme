# == Schema Information
#
# Table name: user_accounts
#
#  id            :integer          not null, primary key
#  uid           :string(255)      not null
#  provider      :string(255)      not null
#  mxit_login    :string(255)
#  real_name     :string(255)
#  mobile_number :string(255)
#  email         :string(255)
#  credits       :integer          default(24)
#  prize_points  :integer          default(0)
#  lock_version  :integer          default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#

class UserAccount < ActiveRecord::Base
  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider

  has_many :redeem_winnings
  has_many :airtime_vouchers
  has_many :purchase_transactions

  def registered_on_mxit_money?(connection = MxitMoneyApi.connect(ENV['MXIT_MONEY_API_KEY']))
    begin
      if connection
        result = connection.user_info(:id => uid)
        result[:is_registered]
      end
    rescue Exception => e
      Airbrake.notify_or_ignore(e,:parameters => {:user => self, :connection => connection})
      false
    end
  end

  def not_registered_on_mxit_money?
    !registered_on_mxit_money?
  end

  def use_credit!
    raise 'not enough credits' if credits <= 0
    decrement!(:credits)
  end
end
