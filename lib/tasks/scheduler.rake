namespace :scheduler do

  namespace :daily do
    desc "what must be run at start of the day"
    task "start_of_day" => :environment do
      User.all.each { |user| user.update_ratings }
      puts
    end

    desc "what must be run at end of the day"
    task "end_of_day" => :environment do
      Winner.create_daily_winners([0,0,0,0,0,0,0,0,0,0])
    end
  end

end