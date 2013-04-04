class Jobs::CreateWeeklyWinners < Jobs::Base

  def run
    # perform work here
    Winner.create_weekly_winners
    Librato::Metrics.annotate :winners, "#{Winner.where(end_of_period_on: Date.current).period('weekly').count} weekly winners #{Time.current.strftime('%F')}"
  end

end