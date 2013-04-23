class IssueMxitMoneyToUsers
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(redeem_winning_id)
    # do something
    winning = RedeemWinning.find(redeem_winning_id)
    if winning.pending?
      connection = MxitMoneyApi.connect(ENV['MXIT_MONEY_API_KEY'])
      user_mxit_info = connection.try(:user_info,:id => winning.user_uid)
      if connection && user_mxit_info[:is_registered]
        result = connection.issue_money(:phone_number => user_mxit_info[:msisdn],
                                        :merchant_reference => "RW#{winning.id}Y#{Time.current.yday}H#{Time.current.hour}",
                                        :amount_in_cents => winning.prize_amount)
        if result[:m2_reference]
          winning.paid!
          winning.update_column(:mxit_money_reference,result[:m2_reference])
        elsif result[:error_type]
          Airbrake.notify_or_ignore(
            Exception.new("#{result[:error_type]}: #{result[:message]}"),
            :parameters    => {:redeem_winning => winning},
            :cgi_data      => ENV
          )
          Settings.mxit_money_disabled_until = 1.day.from_now
        end
      end
    end
  end

end