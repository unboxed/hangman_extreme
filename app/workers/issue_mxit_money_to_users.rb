class IssueMxitMoneyToUsers
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(redeem_winning_id)
    # do something
    @winning = RedeemWinning.find(redeem_winning_id)
    return unless @winning.pending?
    if user_is_registered?
      handle_registered
    else
      handle_unregistered_or_connection_failed
    end
  end

  private

  def handle_registered
    result = connection.issue_money(:phone_number => user_mxit_info[:msisdn],
                                    :merchant_reference => "RW#{@winning.id}Y#{Time.current.yday}H#{Time.current.hour}",
                                    :amount_in_cents => @winning.prize_amount)
    if result[:m2_reference]
      @winning.paid!
      @winning.update_column(:mxit_money_reference,result[:m2_reference])
    else
      exception_msg = "Invalid Result from Mxit Api"
      if result[:error_type]
        exception_msg = "#{result[:error_type]}: #{result[:message]}"
        Settings.mxit_money_disabled_until = 7.days.from_now
      end
      error_notify(exception_msg, :result => result)
    end
  end

  def handle_unregistered_or_connection_failed
    if @connection
      error_notify("User not registered on Mxit Money",{}, false)
      @winning.cancel!
    else
      error_notify("Could not connect to Mxit Api")
    end
  end

  def user_is_registered?
    user_mxit_info[:is_registered]
  end

  def connection
    @connection ||= MxitMoneyApi.connect(ENV['MXIT_MONEY_API_KEY'])
  end

  def user_mxit_info
    @mxit_info ||= (connection.try(:user_info,:id => @winning.user_uid) || {})
  end

  def error_notify(exception_msg, params = {}, raise_error = true)
    Airbrake.notify_or_ignore(exception_msg,
                              :parameters => params.merge(:connection => @connection,
                                                          :mxit_info => @mxit_info,
                                                          :redeem_winning => @winning),
                              :cgi_data   => ENV)
    raise(exception_msg) if raise_error
  end

end