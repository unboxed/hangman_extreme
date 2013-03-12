require "spec_helper"

describe RedeemWinningsController do
  describe "routing" do

    it "routes to #index" do
      get("/airtime_vouchers").should route_to("airtime_vouchers#index")
    end

  end
end
