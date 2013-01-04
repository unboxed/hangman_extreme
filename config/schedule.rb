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
  rake "daily:end_of_day"
end

every :day, :at => '12:01am' do
  rake "daily:start_of_day"
end

every :hour do
  runner "Settings.cron_running!"
end