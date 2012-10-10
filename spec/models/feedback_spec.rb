require 'spec_helper'

describe Feedback do

  before :each do
    Feedback.stub(:subdomain_name).and_return('ubxd')
    Feedback.stub(:api_key).and_return('api_key')
    Feedback.stub(:api_secret).and_return('api_secret')
  end

  context "send_support" do

    it "must send the support" do
      stub_request(:post, "https://ubxd.uservoice.com/api/v1/tickets.json").to_return(:status => 200, :body => "{}", :headers => {})
      Feedback.send_support(email: "test@mail.com", subject: "Test subject", message: "hello")
      assert_requested(:post, "https://ubxd.uservoice.com/api/v1/tickets.json",
                       :body => "{\"email\":\"test@mail.com\",\"ticket\":{\"subject\":\"Test subject\",\"message\":\"hello\"}}")
    end

  end

  context "send_suggestion" do

    it "must send the support" do
      voice = mock('Voice')
      UserVoice::Client.should_receive(:new).and_return(voice)
      voice.should_receive(:get).with("/api/v1/forums.json").and_return("{\"forums\":[{\"id\":123}]}")
      voice.should_receive(:login_as).with("test@mail.com")
      Feedback.send_suggestion(email: "test@mail.com", subject: "Test subject", message: "hello")
    end

  end

end
