require 'mxit_api'

class UserAccount
  include Her::Model

  validates :provider, :uid, presence: true

  def initialize(values = {})
    values.reverse_merge!(uid: nil, provider: nil)
    super
  end

  def self.find_or_create_with(uid_and_provider, defaults)
    where(uid_and_provider).first || create(uid_and_provider.reverse_merge(defaults))
  end

  def increment_prize_points!(amount)
    assign_attributes(prize_points: prize_points + amount)
    save
  end

  #
  #validates :provider, :uid, presence: true
  #validates_uniqueness_of :uid, :scope => :provider
  #
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
    assign_attributes(credits: credits - 1)
    save
  end
end
