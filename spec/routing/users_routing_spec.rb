require "spec_helper"

describe UsersController do

  describe "routing" do

    it "builds mxit authorise" do
      url = mxit_authorise_url(response_type: 'code',
                               host: "auth.mxit.com",
                               client_id: '123',
                               redirect_uri: users_url(host: "test.host"),
                               scope: "profile/private")
      url.should include("http://auth.mxit.com")
      url.should include("response_type=code")
      url.should include("client_id=123")
      url.should include("redirect_uri=http%3A%2F%2Ftest.host%2Fusers")
      url.should include("profile%2Fprivate")
    end

    it "routes to #mxit_oauth" do
      get("/users/mxit_oauth").should route_to("users#mxit_oauth")
    end

    it "routes to #show" do
      get("/users/1").should route_to("users#show", :id => "1")
    end

    it "routes to #profile" do
      get("/users/profile").should route_to("users#profile")
    end

    it "routes to #index" do
      get("/users").should route_to("users#index")
    end

    it "routes to #edit" do
      get("/users/11/edit").should route_to("users#edit", :id => "11")
    end

    it "routes to #update" do
      put("/users/11").should route_to("users#update", :id => "11")
    end

  end
end
