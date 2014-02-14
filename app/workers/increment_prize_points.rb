class IncrementPrizePoints
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(winner_id)
    winner =  Winner.find(winner_id)
    if winner.amount > 0
      winner.user.account.increment_prize_points!(winner.amount)
    end
  end
end
