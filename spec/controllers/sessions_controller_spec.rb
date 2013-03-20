require 'spec_helper'

describe SessionsController do

  before :each do
    controller.stub(:send_stats)
  end

  describe "GET 'create'" do

    before :each do
      User.stub(:find_or_create_from_auth_hash)
    end

    it "must redirect to root path" do
      put 'create', provider: 'test'
      response.should redirect_to(root_path)
    end

    it "must find_or_create_from_auth_hash" do
      request.env['omniauth.auth'] = "auth_info"
      User.should_receive(:find_or_create_from_auth_hash).with("auth_info")
      put 'create', provider: 'test'
    end

  end

end
