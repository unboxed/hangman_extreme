require "spec_helper"

describe RedeemWinningsController do
  describe "routing" do

    it "routes to #index" do
      get("/redeem_winnings").should route_to("redeem_winnings#index")
    end

  end
end
