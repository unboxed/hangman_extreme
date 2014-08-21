require 'spec_helper'

describe ApplicationController do
  describe 'handling CanCan AccessDenied exceptions' do
    controller do
      def index
        raise CanCan::AccessDenied
      end
    end

    it 'redirects to the /401.html page' do
      get :index
      response.should redirect_to('/')
      flash[:alert].should_not be_blank
    end
  end

  describe 'it attempts to load the mxit user' do
    before :each do
      controller.stub(:send_stats)
    end

    controller do
      def index
        render :text => 'hello'
      end
    end

    context 'has mxit headers' do
      before :each do
        create(:user, uid: 'm2604100')
        request.env['HTTP_X_MXIT_USERID_R'] = 'm2604100'
        request.env['HTTP_X_MXIT_NICK'] = 'grant'
        @user_request_info = UserRequestInfo.new
        UserRequestInfo.stub(:new).and_return(@user_request_info)
      end

      it 'loads the mxit user into current_user' do
        User.should_receive(:find_or_create_from_auth_hash).with(uid: 'm2604100',
                                                                 provider: 'mxit',
                                                                 info: {name: 'grant',
                                                                        login: nil,
                                                                        email: nil})
        get :index
      end

      it 'loads the mxit user into current_user' do
        request.env['HTTP_X_MXIT_LOGIN'] = 'gman'
        User.should_receive(:find_or_create_from_auth_hash).with(uid: 'm2604100',
                                                                 provider: 'mxit',
                                                                 info: {name: 'grant',
                                                                        login: 'gman',
                                                                        email: 'gman@mxit.im'})
        get :index
      end

      it 'must assign the mxit user' do
        User.stub(:find_or_create_from_auth_hash).and_return('mxit_user')
        get :index
        assigns(:current_user).should be == 'mxit_user'
      end

      it 'must assign the user request info' do
        request.env['HTTP_X_MXIT_PROFILE'] = 'test'
        get :index
        assigns(:current_user_request_info).should be == @user_request_info
      end

      it 'must assign mxit profile to user request info' do
        request.env['HTTP_X_MXIT_PROFILE'] = 'test'
        MxitProfile.should_receive(:new).with('test').and_return('profile')
        @user_request_info.should_receive(:mxit_profile=).with('profile')
        get :index
      end

      it 'must assign user_agent to user request info' do
        request.env['HTTP_X_DEVICE_USER_AGENT'] = 'iphone'
        @user_request_info.should_receive(:user_agent=).with('Mxit iphone')
        get :index
      end

      it 'must assign mxit profile to user request info' do
        request.env['HTTP_X_MXIT_LOCATION'] = 'test'
        MxitLocation.should_receive(:new).with('test').and_return('location')
        @user_request_info.should_receive(:mxit_location=).with('location')
        get :index
      end
    end
  end

  describe 'sending stats' do
    controller do
      def index
        render :text => 'hello'
      end
    end

    before :each do
      @user = stub_model(User)
      @user_request_info = UserRequestInfo.new
      controller.stub(:tracking_enabled?).and_return(true)
      controller.stub(:current_user).and_return(@user)
      controller.stub(:current_user_request_info).and_return(@user_request_info)
      @page_view = double('Staccato::Pageview',
                          add_custom_dimension: true,
                          add_custom_metric: true,
                          track!: true)
      Staccato::Pageview.stub(:new).and_return(@page_view)
    end

    it 'wont create a new connection if being redirected' do
      controller.stub(:status).and_return(302)
      Staccato::Pageview.should_not_receive(:new)
      get :index
    end

    it 'must create a new connection' do
      controller.stub(:tracking_code).and_return('test')
      Staccato::Pageview.should_receive(:new).with(anything,kind_of(Hash)).and_return(@page_view)
      get :index
    end

    it 'must set the user_agent' do
      @user_request_info.user_agent = 'Mxit Nokia'
      Staccato::Pageview.should_receive(:new).
        with(anything,hash_including(user_agent: 'Rails Testing Mxit Nokia')).
         and_return(@page_view)
      get :index
    end

    it 'must set the user_agent if no user_request_info' do
      request.env['HTTP_USER_AGENT'] = 'iphone'
      Staccato::Pageview.should_receive(:new).
        with(anything,hash_including(user_agent: 'iphone ')).
        and_return(@page_view)
      get :index
    end

    it 'must set the language' do
      @user_request_info.language = 'afr'
      Staccato::Pageview.should_receive(:new).
        with(anything,hash_including(user_language: 'afr')).
        and_return(@page_view)
      get :index
    end

    it 'must set the mxit gender' do
      @user_request_info.gender = 'female'
      @page_view.should_receive(:add_custom_dimension).with(1,'female')
      get :index
    end

    it 'must set the mxit age' do
      @user_request_info.age = '21'
      @page_view.should_receive(:add_custom_metric).with(2,'21')
      get :index
    end

    it 'must set the path' do
      Staccato::Pageview.should_receive(:new).
        with(anything,hash_including(path: '/anonymous')).
        and_return(@page_view)
      get :index
    end

    it 'must send the page view' do
      @page_view.should_receive(:track!)
      get :index
    end
  end

  describe 'it captures mxit user input' do
    before :each do
      controller.stub(:send_stats)
    end

    controller do
      def index
        render :text => 'hello'
      end
    end

    it 'must render page if no user input' do
      get :index
      response.should be_success
    end

    it 'must redirect to mxit invite if input extremepayout' do
      request.env['HTTP_X_MXIT_USER_INPUT'] = 'extremepayout'
      get :index
      response.should redirect_to(mxit_authorise_url(response_type: 'code',
                                                     host: 'test.host',
                                                     protocol: 'http',
                                                     client_id: ENV['MXIT_CLIENT_ID'],
                                                     redirect_uri: mxit_oauth_users_url(host: 'test.host'),
                                                     scope: 'contact/invite graph/read',
                                                     state: 'winnings'))
    end

    it 'must redirect to mxit invite if input extremepayout' do
      request.env['HTTP_X_MXIT_USER_INPUT'] = 'options'
      get :index
      response.should redirect_to(options_users_path)
    end

    it 'must redirect to mxit invite if input extremepayout' do
      request.env['HTTP_X_MXIT_USER_INPUT'] = 'winners'
      get :index
      response.should redirect_to(winners_path)
    end
  end

  describe 'it uses correct layout' do
    controller do
      def index
        render 'games/index', layout: true
      end
    end

    it 'must render layout' do
      get :index
      response.should render_template('layouts/application')
    end
  end
end
