require 'spec_helper'

describe ApplicationController do

  describe "login required" do

    controller do
      before_filter :login_required
      def index
        render :text => "hello"
      end
    end

    it "must redirects to /auth/developer if not user_id" do
      get :index
      response.should redirect_to("/auth/developer")
    end

    it "wont redirects to /auth/developer if logged_in" do
      user = stub_model(User)
      User.should_receive(:find_by_id).with(nil).and_return(user)
      get :index
      response.should be_success
    end

  end

  describe "handling CanCan AccessDenied exceptions" do

    controller do
      def index
        raise CanCan::AccessDenied
      end
    end

    it "redirects to the /401.html page" do
      get :index
      response.should redirect_to("/")
      flash[:alert].should_not be_blank
    end
  end

  describe "it attempts to load the mxit user" do

    controller do
      def index
        render :text => "hello"
      end
    end

    context "has mxit headers" do

      before :each do
        request.env['HTTP_X_MXIT_USERID_R'] = 'm2604100'
        request.env['HTTP_X_MXIT_NICK'] = 'grant'
      end

      it "loads the mxit user into current_user" do
        User.should_receive(:find_or_create_from_auth_hash).with(uid: 'm2604100', provider: 'mxit', info: {name: 'grant'})
        get :index
      end

      it "must assign the mxit user" do
        User.stub!(:find_or_create_from_auth_hash).and_return('mxit_user')
        get :index
        assigns(:current_user).should == 'mxit_user'
      end

    end

    it "wont load mxit user if no userid" do
      User.should_not_receive(:find_or_create_from_auth_hash)
      get :index
      assigns(:current_user).should be_nil
    end

  end

  describe "it attempts to load the facebook user" do

    controller do
      def index
        render :text => "hello"
      end
    end

    it "wont load mxit user if no userid" do
      text = "vlXgu64BQGFSQrY0ZcJBZASMvYvTHu9GQ0YM9rjPSso.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsIjAiOiJwYXlsb2FkIn0"
      User.should_not_receive(:find_or_create_from_auth_hash)
      get :index, signed_request: text
      assigns(:data).should == {"algorithm"=>"HMAC-SHA256", "0"=>"payload"}
    end

  end

  describe "sending stats" do

    controller do
      def index
        render :text => "hello"
      end
    end

    before :each do
      @user = stub_model(User)
      controller.stub(:tracking_enabled?).and_return(true)
      controller.stub(:current_user).and_return(@user)
      @gabba = mock('connection',
                    :user_agent= => '',
                    :utmul= => '',
                    :set_custom_var => '',
                    :cookie_params => '',
                    :page_view => '',
                    :identify_user => '')
      Gabba::Gabba.stub(:new).and_return(@gabba)
    end

    it "must create a new gabba connection" do
      controller.stub(:tracking_code).and_return('test')
      Gabba::Gabba.should_receive(:new).with('test','mxithangmanleague.herokuapp.com').and_return(@gabba)
      get :index
    end

    it "must set the mxit user_agent" do
      request.env['HTTP_X_DEVICE_USER_AGENT'] = "iphone"
      @gabba.should_receive(:user_agent=).with("Mxit iphone")
      get :index
    end

    it "must set the user_agent" do
      request.env['HTTP_USER_AGENT'] = "iphone"
      @gabba.should_receive(:user_agent=).with("iphone")
      get :index
    end

    context "mxit profile" do

      before :each do
        request.env['HTTP_X_MXIT_PROFILE'] = "mxit_profile"
        MxitProfile.stub(:new).and_return(mock('profile', language: 'en', age: 20, gender: 'male'))
      end

      it "must set the language" do
        @gabba.should_receive(:utmul=).with('en')
        get :index
      end

      it "must set the mxit gender" do
        @gabba.should_receive(:set_custom_var).with(1,'Gender','male',1)
        get :index
      end

      it "must set the mxit age" do
        @gabba.should_receive(:set_custom_var).with(2,'Age','20',1)
        get :index
      end

    end

    it "must set the mxit location" do
      request.env['HTTP_X_MXIT_LOCATION'] = "mxit_location"
      MxitLocation.stub(:new).and_return(mock('location', country_name: 'ZA', principal_subdivision_name: 'WC'))
      @gabba.should_receive(:set_custom_var).with(3,'ZA','WC',1)
      get :index
    end

    it "must set the user provider" do
      @user.stub(:provider).and_return("the provider")
      @gabba.should_receive(:set_custom_var).with(5,'Provider','the provider',1)
      get :index
    end

    it "must send the page view" do
      @gabba.should_receive(:page_view).with("anonymous index","/anonymous",@user.id)
      get :index
    end

  end

end