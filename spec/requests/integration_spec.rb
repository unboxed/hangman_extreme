require 'spec_helper'

describe 'jobs' do

  it "must record hourly stats" do
    Jobs::RecordHourlyStats.execute
  end

  it "must record daily stats" do
    Jobs::RecordDailyStats.execute
  end

  it "must record daily stats" do
    Jobs::RecordDailyStats.execute
  end

  it "must record daily stats" do
    Jobs::AddCluePointsToActivePlayers.execute
  end

end