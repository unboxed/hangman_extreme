namespace :scheduler do

  namespace :daily do
    desc "what must be run at start of the day"
    task "start_of_day" => :environment do
      User.new_day_set_scores!
      Game.purge_old!
    end

    desc "what must be run at end of the day"
    task "end_of_day" => :environment do
      Winner.create_daily_winners([20,18,16,14,12,10,8,6,4,2])
      if Date.today == Date.today.end_of_week
        Winner.create_weekly_winners([210,180,160,140,120,100,80,60,40,20])
      end
      #if Date.today == Date.today.end_of_month
      #  Winner.create_monthly_winners([0,0,0,0,0,0,0,0,0,0])
      #end
    end
  end

end