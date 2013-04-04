class Jobs::AddCluePointsToActivePlayers < Jobs::Base

  def run
    # perform work here
    User.add_clue_point_to_active_players!
  end

end