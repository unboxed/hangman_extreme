require "spec_helper"

describe FeedbackController do
  describe "routing" do

    it "routes to #index" do
      get("/user/feedback").should route_to("feedback#index")
    end

    it "routes to #new" do
      get("/user/feedback/new").should route_to("feedback#new")
    end

    it "routes to #create" do
      post("/user/feedback").should route_to("feedback#create")
    end

  end

end
