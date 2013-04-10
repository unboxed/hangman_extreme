class Jobs::RecordDailyStats < Jobs::Base

  def run
    # perform work here
    queue = Librato::Metrics::Queue.new
    queue.add :purchases_per_day => PurchaseTransaction.last_day.sum(:moola_amount)
    queue.add :redeem_winning_per_day => RedeemWinning.last_day.sum(:prize_amount)
    queue.add :active_mxit_per_day => User.active_mxit_today.count
    queue.add :active_mxit_per_day => User.active_non_mxit.count
    queue.submit
  end

end