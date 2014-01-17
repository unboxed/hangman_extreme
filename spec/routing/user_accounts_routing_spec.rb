require "spec_helper"

describe UserAccountsController do
  describe "routing" do
    it "routes to #profile" do
      get("/profile").should route_to("user_accounts#show")
    end

    it "routes to #edit" do
      get("/profile/edit").should route_to("user_accounts#edit")
    end

    it "routes to #update" do
      patch("/profile").should route_to("user_accounts#update")
    end
  end
end
