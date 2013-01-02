require "spec_helper"

describe FeedbackController do
  describe "routing" do

    it "routes to #index" do
      get("/feedback").should route_to("feedback#index")
    end

    it "routes to #new" do
      get("/feedback/new").should route_to("feedback#new")
    end

    it "routes to #create" do
      post("/feedback").should route_to("feedback#create")
    end

    it "routes to #create" do
      get("/server_status").should route_to("feedback#server_status")
    end

  end

end
