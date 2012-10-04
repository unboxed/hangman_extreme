require "spec_helper"

describe WinnersController do

  describe "routing" do

    it "routes to #index" do
      get("/winners").should route_to("winners#index")
    end

  end
end
