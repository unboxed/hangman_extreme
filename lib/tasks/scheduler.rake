namespace :scheduler do

  namespace :daily do
    desc "what must be run at start of the day"
    task "start_of_day" => :environment do
      User.all.each { |user| user.update_ratings }
      puts
    end

    desc "what must be run at end of the day"
    task "end_of_day" => :environment do
      Winner.create_daily_winners([20,18,16,14,12,10,8,6,4,2])
    end
  end

end