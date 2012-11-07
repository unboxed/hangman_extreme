namespace :scheduler do

  namespace :daily do
    desc "what must be run at start of the day"
    task "start_of_day" => :environment do
      User.new_day_set_scores!
      Game.purge_old!
      # clear unused google tracking
      User.where('updated_at < ?',4.days.ago).each{|u| u.google_tracking.delete }.size
    end

    desc "what must be run at end of the day"
    task "end_of_day" => :environment do
      Winner.create_daily_winners
      if Date.current == Date.current.end_of_week
        Winner.create_weekly_winners
      end
      User.add_clue_point_to_active_players!
    end
  end

end