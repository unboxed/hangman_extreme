require 'spec_helper'

describe Jobs::CreateWeeklyWinners do

  describe "run" do

    it "must run" do
      Winner.should_receive(:create_weekly_winners)
      Jobs::CreateWeeklyWinners.new.run
    end

  end

  describe "on_error" do

    it "must send the error to airbrake" do
      Airbrake.should_receive(:notify_or_ignore).with("Error!",anything())
      Jobs::CreateWeeklyWinners.new.on_error("Error!")
    end

  end

end
