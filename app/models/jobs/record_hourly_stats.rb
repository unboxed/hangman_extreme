class Jobs::RecordHourlyStats < Jobs::Base

  def run
    # perform work here
    queue = Librato::Metrics::Queue.new
    queue.add :new_games_per_hour => Game.last_hour.count
    queue.add :active_users_per_hour => User.active_last_hour.count
    queue.add :active_mxit_users => User.active_mxit.count
    queue.add :active_non_mxit_users => User.active_non_mxit.count
    queue.submit
  end

end