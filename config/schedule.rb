# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
set :output, 'cron.log'


every :day, :at => '11:45pm' do
  runner "Winner.create_daily_winners"
  runner "Winner.add_clue_point_to_active_players!"
end
every :sunday, :at => '11:45pm' do
  runner "Winner.create_weekly_winners"
end

every :day, :at => '12:01am' do
  runner "User.new_day_set_scores!"
end

every :monday, :at => '12:01am' do
  runner "Game.purge_old!"
  runner "User.purge_tracking!"
end