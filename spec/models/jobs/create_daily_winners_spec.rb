require 'spec_helper'

describe Jobs::CreateDailyWinners do

  describe "run" do

    it "must run" do
      Winner.should_receive(:create_daily_winners)
      Jobs::CreateDailyWinners.new.run
    end

  end

  describe "on_error" do

    it "must send the error to airbrake" do
      Airbrake.should_receive(:notify_or_ignore).with("Error!",anything())
      Jobs::CreateDailyWinners.new.on_error("Error!")
    end

  end

end
