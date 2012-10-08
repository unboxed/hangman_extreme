require 'spec_helper'

describe MxitApi do

  before :each do
    MxitApi.stub(:client_id).and_return("1")
    MxitApi.stub(:client_secret).and_return("1")
    token_body = %&{"access_token":"c71219af53f5409e9d1db61db8a08248",
                    "token_type":"bearer",
                    "expires_in":3600,
                    "refresh_token":"7f4b56bda11e4f7ba84c9e35c76b7aea",
                    "scope":"message"}&
    stub_request(:post, "https://1:1@auth.mxit.com/token").to_return(:status => 200, :body => token_body, :headers => {})
  end

  context "new" do

    it "must post to mxit api requesting token" do
      MxitApi.new("456","http://www.hangman_league.dev/users/mxit_oauth")
      assert_requested(:post, "https://1:1@auth.mxit.com/token",
                       :body => "grant_type=authorization_code&code=456&redirect_uri=http%3A%2F%2Fwww.hangman_league.dev%2Fusers%2Fmxit_oauth",
                       :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'})
    end

    it "must set the access_token" do
      connection = MxitApi.new("456","/")
      connection.access_token.should == "c71219af53f5409e9d1db61db8a08248"
    end

    it "must set the token_type" do
      connection = MxitApi.new("456","/")
      connection.token_type.should == "bearer"
    end

    it "must set expire_at" do
      Timecop.freeze do
        connection = MxitApi.new("456","/")
        connection.expire_at.should == 1.hour.from_now
      end
    end

    it "must set the refresh_token" do
      connection = MxitApi.new("456","/")
      connection.refresh_token.should == "7f4b56bda11e4f7ba84c9e35c76b7aea"
    end

    it "must set the scope" do
      connection = MxitApi.new("456","/")
      connection.scope.should == "message"
    end

    it "must handle a failed response" do
      stub_request(:post, "https://1:1@auth.mxit.com/token").to_return(:status => 401, :body => '', :headers => {})
      connection = MxitApi.new("456","/")
      connection.access_token.should be_nil
    end

  end

  context "connect" do

    it "must return connection if has access_token" do
      connection = mock('MxitApi', access_token: "123")
      MxitApi.should_receive(:new).with("123","/new").and_return(connection)
      MxitApi.connect("123","/new").should == connection
    end

    it "wont return connection if not access_token" do
      connection = mock('MxitApi', access_token: nil)
      MxitApi.should_receive(:new).with("123","/new").and_return(connection)
      MxitApi.connect("123","/new").should be_nil
    end

  end

  context "profile" do

    before :each do
      body = %&{ "DisplayName":"String content",
                 "AvatarId":"String content",
                 "State":{
                      "Availability":0,
                      "IsOnline":true,
                      "LastModified":"\\/Date(928142400000+0200)\\/",
                      "LastOnline":"\\/Date(928142400000+0200)\\/",
                      "Mood":0,
                      "StatusMessage":"String content"
                  },
                  "UserId":"String content",
                  "AboutMe":"String content",
                  "Age":32767,
                  "FirstName":"Grant",
                  "Gender":0,
                  "LanguageCode":"String content",
                  "LastKnownCountryCode":"String content",
                  "LastName":"Speelman",
                  "NetworkOperatorCode":"String content",
                  "RegisteredCountryCode":"String content",
                  "RegistrationDate":"\\/Date(928142400000+0200)\\/",
                  "StatusMessage":"String content",
                  "Title":"String content",
                  "CurrentCultureName":"String content",
                  "DateOfBirth":"\\/Date(928142400000+0200)\\/",
                  "Email":"String content",
                  "MobileNumber":"0821234567",
                  "RelationshipStatus":0,
                  "WhereAmI":"String content"
                }&
      stub_request(:get, "https://api.mxit.com/user/profile").to_return(:status => 200, :body => body, :headers => {})
      @connection = MxitApi.new("456","/")
    end

    it "must return a hash of the profile" do
      profile = @connection.profile
      profile.should be_kind_of(Hash)
      profile[:first_name].should == "Grant"
      profile[:last_name].should == "Speelman"
      profile[:mobile_number].should == "0821234567"
    end

    it "must make the correct api request" do
      @connection.stub(:access_token).and_return("c71219af53f5409e9d1db61db8a08248")
      @connection.stub(:token_type).and_return("bearer")
      @connection.profile
      assert_requested(:get, "https://api.mxit.com/user/profile",
                       :headers => {'Accept'=>'application/json',
                                    'Authorization'=>'bearer c71219af53f5409e9d1db61db8a08248',
                                    'User-Agent'=>'Ruby'})
    end

    it "must handle a failed response" do
      stub_request(:get, "https://api.mxit.com/user/profile").to_return(:status => 401, :body => '', :headers => {})
      profile = @connection.profile
      profile.should be_empty
    end

  end

end
