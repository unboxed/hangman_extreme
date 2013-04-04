require 'spec_helper'

describe Jobs::IssueMxitMoneyToUsers do

  describe "run" do

    it "must run issue_mxit_money_to_users on RedeemWinning" do
      RedeemWinning.should_receive(:issue_mxit_money_to_users)
      Jobs::IssueMxitMoneyToUsers.new.run
    end

  end

  describe "on_error" do

    it "must send the error to airbrake" do
      Airbrake.should_receive(:notify_or_ignore).with("Error!",anything())
      Jobs::IssueMxitMoneyToUsers.new.on_error("Error!")
    end

  end

end