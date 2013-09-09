require 'features_helper'

describe 'jobs' do

  it "must record hourly stats" do
    Jobs::RecordHourlyStats.execute
  end

  it "must record daily stats" do
    Jobs::RecordDailyStats.execute
  end

  it "must update user credits" do
    create(:user, :credits => 0)
    Jobs::SetUserCredits.execute
  end

end
