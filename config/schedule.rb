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
set :output, "/home/hmx/current/log/cron_log.log"

every :day, :at => '11:55 pm', :roles => [:db] do
  runner "Jobs::CreateDailyWinners.execute"
end

every :day, :at => '00:00 am', :roles => [:db] do
  runner "Jobs::NewDaySetScores.execute"
  runner "Jobs::RecordDailyStats.execute"
end

every :day, :at => '11:58 pm', :roles => [:db] do
  runner "Jobs::AddCluePointsToActivePlayers.execute"
end

every :sunday, :at => '11:55 pm', :roles => [:db] do
  runner "Jobs::CreateWeeklyWinners.execute"
end

every 30.minutes, :roles => [:db] do
  runner "Jobs::IssueMxitMoneyToUsers.execute"
  runner "Jobs::IssueAirtimeToUsers.execute"
end

every :hour, :roles => [:db] do
  runner "Jobs::RecordHourlyStats.execute"
end
