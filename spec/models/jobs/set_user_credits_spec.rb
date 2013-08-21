require 'spec_helper'

describe Jobs::SetUserCredits do

  describe "run" do

    context "add_clue_point_to_active_players!" do

      it "must set user credits to 18" do
        user = create(:game, user: create(:user, credits: 2)).user
        Jobs::SetUserCredits.new.run
        user.reload
        user.credits.should == 18
      end

      it "wont decrease user credits to 18" do
        user = create(:user, credits: 19)
        Jobs::SetUserCredits.new.run
        user.reload
        user.credits.should == 19
      end

    end

  end

  describe "on_error" do

    it "must send the error to airbrake" do
      Airbrake.should_receive(:notify_or_ignore).with("Error!",anything())
      Jobs::SetUserCredits.new.on_error("Error!")
    end

  end

end