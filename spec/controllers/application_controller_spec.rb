require 'spec_helper'

describe ApplicationController do
  describe "login required" do
    before :each do
      controller.stub(:send_stats)
    end

    controller do
      before_filter :login_required
      def index
        render :text => "hello"
      end
    end

    it "must redirects to root_path if not user_id" do
      get :index
      response.should redirect_to(root_path)
    end

    it "should find the user" do
      User.should_receive(:find_by).with(kind_of(Hash)).and_return(stub_model(User, uid: '123', provider: '123'))
      get :index
    end

    it "wont redirects to root_path if logged_in" do
      User.stub(:find_by).and_return(stub_model(User, uid: '123', provider: '123'))
      get :index
      response.should be_success
    end
  end

  describe "load_guest_user" do
    before :each do
      controller.stub(:send_stats)
    end

    controller do
      def index
        render :text => "hello"
      end
    end

    it "must assign a guest current_user" do
      get :index
      assigns(:current_user).should be_kind_of(User)
      assigns(:current_user).should be_a_guest
    end

    it "wont assign a guest current_user if already a user" do
      request.env['HTTP_X_MXIT_USERID_R'] = 'm2604100'
      get :index
      assigns(:current_user).should_not be_a_guest
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
    before :each do
      controller.stub(:send_stats)
    end

    controller do
      def index
        render :text => "hello"
      end
    end

    context "has mxit headers" do

      before :each do
        request.env['HTTP_X_MXIT_USERID_R'] = 'm2604100'
        request.env['HTTP_X_MXIT_NICK'] = 'grant'
        @user_request_info = UserRequestInfo.new
        UserRequestInfo.stub(:new).and_return(@user_request_info)
      end

      it "loads the mxit user into current_user" do
        User.should_receive(:find_or_create_from_auth_hash).with(uid: 'm2604100',
                                                                 provider: 'mxit',
                                                                 info: {name: 'grant',
                                                                        login: nil,
                                                                        email: nil})
        get :index
      end

      it "loads the mxit user into current_user" do
        request.env['HTTP_X_MXIT_LOGIN'] = 'gman'
        User.should_receive(:find_or_create_from_auth_hash).with(uid: 'm2604100',
                                                                 provider: 'mxit',
                                                                 info: {name: 'grant',
                                                                        login: "gman",
                                                                        email: "gman@mxit.im"})
        get :index
      end

      it "must assign the mxit user" do
        User.stub(:find_or_create_from_auth_hash).and_return('mxit_user')
        get :index
        assigns(:current_user).should == 'mxit_user'
      end

      it "must assign the user request info" do
        request.env['HTTP_X_MXIT_PROFILE'] = 'test'
        get :index
        assigns(:current_user_request_info).should == @user_request_info
      end

      it "must assign mxit profile to user request info" do
        request.env['HTTP_X_MXIT_PROFILE'] = 'test'
        MxitProfile.should_receive(:new).with('test').and_return('profile')
        @user_request_info.should_receive(:mxit_profile=).with('profile')
        get :index
      end

      it "must assign user_agent to user request info" do
        request.env['HTTP_X_DEVICE_USER_AGENT'] = 'iphone'
        @user_request_info.should_receive(:user_agent=).with('Mxit iphone')
        get :index
      end

      it "must assign mxit profile to user request info" do
        request.env['HTTP_X_MXIT_LOCATION'] = 'test'
        MxitLocation.should_receive(:new).with('test').and_return('location')
        @user_request_info.should_receive(:mxit_location=).with('location')
        get :index
      end

    end

    it "wont load mxit user if no userid" do
      User.should_not_receive(:find_or_create_from_auth_hash)
      get :index
      assigns(:current_user).should be_a_guest
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
      @user_request_info = UserRequestInfo.new
      controller.stub(:tracking_enabled?).and_return(true)
      controller.stub(:mxit_request?).and_return(true)
      controller.stub(:current_user).and_return(@user)
      controller.stub(:current_user_request_info).and_return(@user_request_info)
      @gabba = double('connection',
                    :ip => '',
                    :user_agent= => '',
                    :utmul= => '',
                    :set_custom_var => '',
                    :cookie_params => '',
                    :page_view => '',
                    :identify_user => '')
      Gabba::Gabba.stub(:new).and_return(@gabba)
    end

    it "wont create a new gabba connection if being redirected" do
      controller.stub(:status).and_return(302)
      Gabba::Gabba.should_not_receive(:new)
      get :index
    end

    it "wont create a new gabba connection if not mxit request" do
      controller.stub(:mxit_request?).and_return(false)
      Gabba::Gabba.should_not_receive(:new)
      get :index
    end

    it "must create a new gabba connection" do
      controller.stub(:tracking_code).and_return('test')
      Gabba::Gabba.should_receive(:new).with('test','test.host').and_return(@gabba)
      get :index
    end

    it "must set the user_agent" do
      @user_request_info.user_agent = "Mxit Nokia"
      @gabba.should_receive(:user_agent=).with("Mxit Nokia")
      get :index
    end

    it "must set the user_agent if no user_request_info" do
      request.env['HTTP_USER_AGENT'] = "iphone"
      @gabba.should_receive(:user_agent=).with("iphone")
      get :index
    end

    it "must set the language" do
      @user_request_info.language = "afr"
      @gabba.should_receive(:utmul=).with("afr")
      get :index
    end

    it "must set the mxit gender" do
      @user_request_info.gender = "female"
      @gabba.should_receive(:set_custom_var).with(1,'Gender','female',1)
      get :index
    end

    it "must set the mxit age" do
      @user_request_info.age = "21"
      @gabba.should_receive(:set_custom_var).with(2,'Age','21',1)
      get :index
    end

    it "must set the mxit location" do
      @user_request_info.country = "South Africa"
      @user_request_info.area = "Cape"
      @gabba.should_receive(:set_custom_var).with(3,'South Africa','Cape',1)
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

  describe "it captures mxit user input" do
    before :each do
      controller.stub(:send_stats)
    end

    controller do
      def index
        render :text => "hello"
      end
    end

    it "must render page if no user input" do
      get :index
      response.should be_success
    end

    it "must redirect to mxit invite if input extremepayout" do
      request.env['HTTP_X_MXIT_USER_INPUT'] = "extremepayout"
      get :index
      response.should redirect_to(mxit_authorise_url(response_type: 'code',
                                                     host: "test.host",
                                                     protocol: 'http',
                                                     client_id: ENV['MXIT_CLIENT_ID'],
                                                     redirect_uri: mxit_oauth_users_url(host: 'test.host'),
                                                     scope: "contact/invite graph/read",
                                                     state: "winnings"))
    end

    it "must redirect to mxit invite if input extremepayout" do
      request.env['HTTP_X_MXIT_USER_INPUT'] = "profile"
      get :index
      response.should redirect_to(user_accounts_path)
    end

    it "must redirect to mxit invite if input extremepayout" do
      request.env['HTTP_X_MXIT_USER_INPUT'] = "winners"
      get :index
      response.should redirect_to(winners_path)
    end
  end

  describe "it uses correct layout" do
    controller do
      layout :set_layout

      def index
        render "games/index", layout: true
      end
    end

    it "must render mobile layout" do
      get :index
      response.should render_template("layouts/mobile")
    end

    it "must render mxit layout" do
      controller.stub(:send_stats)
      request.env['HTTP_X_MXIT_USERID_R'] = "m123"
      get :index
      response.should render_template("layouts/mxit")
    end
  end
end
