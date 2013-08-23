class IssueWinningToUser
  include Sidekiq::Worker
  # retry twice a day for 7 days
  sidekiq_options :backtrace => true, :retry => 14
  sidekiq_retry_in{ |count| 12.hours }

  sidekiq_retries_exhausted do |msg|
    RedeemWinning.find(msg['args'].first).cancel!
  end

  def perform(redeem_winning_id)
    redeem_winning = RedeemWinning.find(redeem_winning_id)
    return unless redeem_winning.pending?
    redeem(redeem_winning)
  end

  def redeem(redeem_winning)
    raise
  end

end
