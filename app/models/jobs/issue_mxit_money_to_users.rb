class Jobs::IssueMxitMoneyToUsers < Jobs::Base

  def run
    # perform work here
    RedeemWinning.issue_mxit_money_to_users
  end

end