require 'spec_helper'

describe UsersController do
  before :each do
    @current_user = create(:user)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can(:manage, :all)
    controller.stub(:current_ability).and_return(@ability)
    controller.stub(:current_user).and_return(@current_user)
    controller.stub(:send_stats)
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end

    it "assigns the requested user as @user" do
      get 'show'
      assigns(:user).should eq(@current_user)
      assigns(:user).should be_decorated
    end
  end

  describe "GET 'mxit_oauth'" do
    before :each do
      @connection = double('MxitApi', access_token: "123", profile: {}, scope: "profile")
      MxitApiWrapper.stub(:new).and_return(@connection)
      @account = double('UserAccount').as_null_object
      @current_user.stub(:account).and_return(@account)
    end

    it "must create a new mxit connection" do
      MxitApiWrapper.should_receive(:connect).with(:grant_type => 'authorization_code',
                                                   :code => "123",
                                                   :redirect_uri => mxit_oauth_users_url(host: 'test.host')).and_return(@connection)
      get 'mxit_oauth', code: "123"
    end

    it "Sets a alert if no code" do
      get 'mxit_oauth'
      flash[:alert].should_not be_blank
    end

    it "returns redirects to options page" do
      get 'mxit_oauth'
      response.should redirect_to(options_users_path)
    end

    it "returns redirects to feedback page if state is feedback" do
      get 'mxit_oauth', state: 'feedback'
      response.should redirect_to(feedback_index_path)
    end

    context "send invite" do
      it "returns sets and save profile information" do
        @connection.stub(:scope).and_return("contact/invite")
        @connection.should_receive(:send_invite).with("m40363966002")
        get 'mxit_oauth', code: "123"
      end
    end

    context "profile" do
      it "returns sets real_name if blank" do
        @connection.should_receive(:profile).and_return(:first_name => "Grant",
                                                        :last_name => "Speelman",
                                                        :mobile_number => "0821234567")
        @account.stub(:real_name).and_return('')
        @account.should_receive(:real_name=).and_return('Grant Speelman')
        get 'mxit_oauth', code: "123"
      end

      it "wont sets real_name if present" do
        @connection.should_receive(:profile).and_return(:first_name => "Grant",
                                                        :last_name => "Speelman",
                                                        :mobile_number => "0821234567")
        @account.stub(:real_name).and_return('other')
        @account.should_not_receive(:real_name=)
        get 'mxit_oauth', code: "123"
      end

      it "returns sets mobile_number if blank" do
        @connection.should_receive(:profile).and_return(:first_name => "Grant",
                                                        :last_name => "Speelman",
                                                        :mobile_number => "0821234567")
        @account.stub(:mobile_number).and_return('')
        @account.should_receive(:mobile_number=).with('0821234567')
        get 'mxit_oauth', code: "123"
      end

      it "wont sets mobile_number if present" do
        @connection.should_receive(:profile).and_return(:first_name => "Grant",
                                                        :last_name => "Speelman",
                                                        :mobile_number => "0821234567")
        @account.stub(:mobile_number).and_return('123123')
        @account.should_not_receive(:mobile_number=)
        get 'mxit_oauth', code: "123"
      end

      it "returns usings mxit.im address if no email set" do
        @connection.should_receive(:profile).and_return(:user_id => "gman")
        @account.stub(:email).and_return('')
        @account.should_receive(:email=).with('gman@mxit.im')
        get 'mxit_oauth', code: "123"
      end
    end
  end

  describe "GET index" do
    def do_get_index(params = {})
      get :index, params
    end

    ['daily', 'weekly'].each do |period|
      ['streak', 'rating'].each do |ranking|
        it "assigns all top #{period} #{ranking} users as @users" do
          user = create(:user)
          do_get_index :rank_by => ranking, :period => period
          assigns(:users).should include(user)
          controller.params[:rank_by].should == ranking
          controller.params[:period].should == period
        end
      end
    end

    it "assigns all users as @users" do
      user = create(:user)
      do_get_index
      assigns(:users).should include(user)
    end

    it "renders successfully" do
      do_get_index
      response.should be_success
    end
  end
end
