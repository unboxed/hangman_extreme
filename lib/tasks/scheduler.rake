namespace :scheduler do

  namespace :daily do
    desc "what must be run at start of the day"
    task "start_of_day" => :environment do
      User.all.each { |user| user.update_ratings }
      User.where('updated_at > ?',1.days.ago).each do |user|
        user.increment!(:clue_points)
      end
      Game.purge_old
    end

    desc "what must be run at end of the day"
    task "end_of_day" => :environment do
      Winner.create_daily_winners([20,18,16,14,12,10,8,6,4,2])
    end
  end

  namespace :weekly do
    desc "what must be run at end of the week"
    task "end_of_week" => :environment do
      Winner.create_weekly_winners([0,0,0,0,0,0,0,0,0,0])
    end
  end

  namespace :monthly do
    desc "what must be run at end of the month"
    task "end_of_month" => :environment do
      Winner.create_monthly_winners([0,0,0,0,0,0,0,0,0,0])
    end
  end

end