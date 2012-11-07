namespace :scheduler do

  namespace :daily do
    desc "what must be run at start of the day"
    task "start_of_day" => :environment do
      User.new_day_set_scores!
      Game.purge_old!
    end

    desc "what must be run at end of the day"
    task "end_of_day" => :environment do
      Winner.create_daily_winners
      if Date.current == Date.current.end_of_week
        Winner.create_weekly_winners
      end
      #if Date.today == Date.today.end_of_month
      #  Winner.create_monthly_winners([0,0,0,0,0,0,0,0,0,0])
      #end
      User.add_clue_point_to_active_players!
    end
  end

end