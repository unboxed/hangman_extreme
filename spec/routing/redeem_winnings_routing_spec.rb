require "spec_helper"

describe RedeemWinningsController do
  describe "routing" do

    it "routes to #index" do
      get("/redeem_winnings").should route_to("redeem_winnings#index")
    end

    it "routes to #new" do
      get("/redeem_winnings/new").should route_to("redeem_winnings#new")
    end

    it "routes to #create" do
      post("/redeem_winnings").should route_to("redeem_winnings#create")
    end

  end
end
