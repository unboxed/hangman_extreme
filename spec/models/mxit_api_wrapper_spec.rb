require 'spec_helper'

describe MxitApiWrapper do

  before :each do
    MxitApiWrapper.stub(:client_id).and_return("1")
    MxitApiWrapper.stub(:client_secret).and_return("2")
  end

  context "new" do

    it "must make mxit api connection" do
      options = {grant_type: 'authorization_code', code: "456", redirect_uri: "http://www.hangman_league.dev/users/mxit_oauth"}
      MxitApi.should_receive(:new).with("1","2",options)
      MxitApiWrapper.new(options)
    end

  end

  context "connect" do

    it "must return connection if has access_token" do
      connection = mock('MxitApi', access_token: "123")
      MxitApiWrapper.should_receive(:new).with(:grant_type => 'authorization_code',
                                        :code => "456",
                                        :redirect_uri => "/").and_return(connection)
      MxitApiWrapper.connect(:grant_type => 'authorization_code',
                      :code => "456",
                      :redirect_uri => "/").should == connection
    end

    it "wont return connection if not access_token" do
      connection = mock('MxitApi', access_token: nil)
      MxitApiWrapper.should_receive(:new).with(:grant_type => 'authorization_code',
                                        :code => "456",
                                        :redirect_uri => "/").and_return(connection)
      MxitApiWrapper.connect(:grant_type => 'authorization_code',
                      :code => "456",
                      :redirect_uri => "/").should be_nil
    end

  end

  context "send_message" do

    it "must be able to handle a exception" do
      mxit_api = mock("MxitApi")
      MxitApi.stub(:new).and_return(mxit_api)
      connection = MxitApiWrapper.new

      ENV['MXIT_APP_NAME'], old =  "testname", ENV['MXIT_APP_NAME']
      Timecop.freeze do
        mxit_api.should_receive(:send_message).with(to: "m123", body: "Hello from the Mxit Api", from: "testname", spool_timeout: 23.hours)
        connection.send_message(:to => "m123", :body => "Hello from the Mxit Api")
      end
      ENV['MXIT_APP_NAME'] = old
    end

  end

end
