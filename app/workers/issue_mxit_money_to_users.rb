require 'mxit_api'

class IssueMxitMoneyToUsers < IssueWinningToUser

  def redeem(redeem_winning)
    # do something
    if connection.balance >= redeem_winning.prize_amount
      user_mxit_info = connection.user_info(:id => redeem_winning.user_account_uid)
      if user_mxit_info[:is_registered]
        result = connection.issue_money(:phone_number => user_mxit_info[:msisdn],
                                        :merchant_reference => "RW#{redeem_winning.id}Y#{Time.current.yday}H#{Time.current.hour}",
                                        :amount_in_cents => redeem_winning.prize_amount)
        if result && result[:m2_reference]
          redeem_winning.paid!
          redeem_winning.update_column(:mxit_money_reference,result[:m2_reference])
        else
          exception_msg = "Invalid Result from Mxit Api: #{result.inspect}"
          exception_msg = "#{result[:error_type]}: #{result[:message]}" if result && result[:error_type]
          raise(exception_msg)
        end
      else
        redeem_winning.cancel!
      end
    else
      raise("No enough mxit money: balance:#{connection.balance} >= prize_amount:#{redeem_winning.prize_amount}")
    end
  end

  private

  def connection
    return @connection if @connection
    @connection = MxitMoneyApi.connect(ENV['MXIT_MONEY_API_KEY'])
    raise("Could not connect to Mxit Api") unless @connection
    @connection
  end

end
