class Jobs::CreateDailyWinners < Jobs::Base
  def run
    # perform work here
    Winner.create_daily_winners
  end
end
