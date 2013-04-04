class Jobs::NewDaySetScores < Jobs::Base

  def run
    # perform work here
    User.new_day_set_scores!
  end

end