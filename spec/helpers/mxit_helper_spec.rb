require 'spec_helper'

describe MxitHelper do
  describe "mxit_authorise_link" do
    it "must work" do
      helper.mxit_authorise_link("name", state: "testing")
    end
  end

  describe "mxit_auth_url" do
    it "must work" do
      helper.mxit_auth_url(state: "profile").should == "http://test.host/authorize?client_id=1&redirect_uri=http%3A%2F%2Ftest.host%2Fusers%2Fmxit_oauth&response_type=code&scope=profile%2Fpublic+profile%2Fprivate&state=profile"
    end
  end
end
