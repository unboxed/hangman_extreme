require 'spec_helper'

describe FeedbackController do

  before :each do
    @current_user = create(:user)
    controller.stub(:current_user).and_return(@current_user)
    controller.stub(:send_stats)
  end

  describe "GET index" do

    def do_get_index
      get :index
    end

    it "renders the application layout" do
      do_get_index
      response.should render_template("layouts/application")
    end

  end

  describe "GET new" do

    def do_get_new
      get :new
    end

    it "renders the application layout" do
      do_get_new
      response.should render_template("layouts/application")
    end

  end

  describe "POST create" do

    def do_create(type = nil)
      post :create,
           :feedback => "The message:The very long part of the message",
           :type => type
    end

    before :each do
      @current_user.real_name = "Grant"
      @current_user.uid = "m123"
      @current_user.provider = "mxit"
      @current_user.email = "m123_mxit@noreply.io"
      Feedback.should respond_to(:send_suggestion)
      Feedback.should respond_to(:send_support)
      Feedback.stub :send_support
      Feedback.stub :send_suggestion
    end

    it "must send support feedback" do
      Feedback.should_receive(:send_support).with(:email => 'm123_mxit@noreply.io',
                                                  :subject => 'The message',
                                                  :message => "The very long part of the message",
                                                  :name => "Grant")
      do_create
    end

    it "must send suggestion feedback" do
      Feedback.should_receive(:send_suggestion).with(:email => 'm123_mxit@noreply.io',
                                                     :subject => 'The message',
                                                     :message => "The very long part of the message",
                                                     :name => "Grant")
      do_create 'suggestion'
    end

    it "wont send feedback if no feedback" do
      Feedback.should_not_receive(:send_suggestion)
      Feedback.should_not_receive(:send_support)
      post :create, :feedback => ""
    end

    it "redirects to home" do
      do_create
      response.should redirect_to(root_path)
    end

    it "redirects to home if error occurs" do
      Rails.logger.should_receive(:error).with("error")
      Feedback.stub(:send_support).and_raise("error")
      Rails.env.stub(:test?).and_return(false)
      do_create
      response.should redirect_to(root_path)
    end

  end

end
