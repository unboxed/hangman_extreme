class Jobs::CreateWeeklyWinners < Jobs::Base
  def run
    # perform work here
    Winner.create_weekly_winners
  end
end
