class Jobs::CreateDailyWinners < Jobs::Base

  def run
    # perform work here
    Winner.create_daily_winners
    Librato::Metrics.annotate :winners, "#{Winner.where(end_of_period_on: Date.current).period('daily').count} daily winners #{Time.current.strftime('%F')}"
  end

end