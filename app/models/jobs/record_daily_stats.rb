class Jobs::RecordDailyStats < Jobs::Base

  def run
    # perform work here
    queue = Librato::Metrics::Queue.new
    queue.add :purchases_per_hour => PurchaseTransaction.last_day.sum(:moola_amount)
    queue.add :redeem_winning_per_hour => RedeemWinning.last_day.sum(:prize_amount)
    queue.submit
  end

end