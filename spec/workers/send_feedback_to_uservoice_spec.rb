require 'spec_helper'

describe SendFeedbackToUservoice do

  before :each do
    @send_feedback_to_uservoice =  SendFeedbackToUservoice.new
    @send_feedback_to_uservoice.stub(:subdomain_name).and_return('ubxd')
    @send_feedback_to_uservoice.stub(:api_key).and_return('api_key')
    @send_feedback_to_uservoice.stub(:api_secret).and_return('api_secret')
  end

  describe "perform" do

    before :each do
      @user = stub_model(User, real_name: "Grant", email: "m123_mxit@noreply.io")
      @feedback = stub_model(Feedback, subject: 'The message', message: 'long part', user: @user)
      Feedback.stub(:find).and_return(@feedback)
      @send_feedback_to_uservoice.stub(:send_suggestion)
    end

    it "must find the feedback" do
      Feedback.should_receive(:find).with(123).and_return(@feedback)
      @send_feedback_to_uservoice.perform(123)
    end

    it "must send support" do
      @feedback.support_type = 'support'
      @send_feedback_to_uservoice.should_receive(:send_support).
        with(email: 'm123_mxit@noreply.io', subject: 'The message', message: "long part", name: "Grant")
      @send_feedback_to_uservoice.perform(123)
    end

    it "must send suggestion" do
      @feedback.support_type = 'suggestion'
      @send_feedback_to_uservoice.should_receive(:send_suggestion).
        with(email: 'm123_mxit@noreply.io', subject: 'The message', message: "long part", name: "Grant")
      @send_feedback_to_uservoice.perform(123)
    end

  end

  describe "send_support" do

    it "must send the support" do
      stub_request(:post, "https://ubxd.uservoice.com/api/v1/tickets.json").to_return(:status => 200, :body => "{}", :headers => {})
      @send_feedback_to_uservoice.send_support(name: "Grant", email: "test@mail.com", subject: "Test subject", message: "hello")
      assert_requested(:post, "https://ubxd.uservoice.com/api/v1/tickets.json",
                       :body => '{"email":"test@mail.com","name":"Grant","ticket":{"subject":"Test subject","message":"hello"}}')
    end

  end

  describe "send_suggestion" do

    it "must send the support" do
      voice = mock('Voice')
      UserVoice::Client.should_receive(:new).and_return(voice)
      voice.should_receive(:get).with("/api/v1/forums.json").and_return("{\"forums\":[{\"id\":123}]}")
      voice.should_receive(:login_as).with("test@mail.com")
      @send_feedback_to_uservoice.send_suggestion(email: "test@mail.com", subject: "Test subject", message: "hello")
    end

  end

end