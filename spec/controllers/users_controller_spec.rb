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

    it "returns redirects to profile page" do
      get 'mxit_oauth'
      response.should redirect_to(user_accounts_path)
    end

    it "returns redirects to feedback page if state is feedback" do
      get 'mxit_oauth', state: 'feedback'
      response.should redirect_to(feedback_index_path)
    end

    it "returns redirects to winnings page if state is winnings" do
      get 'mxit_oauth', state: 'winnings'
      response.should redirect_to(redeem_winnings_path)
    end

    context "send invite" do
      it "returns sets and save profile information" do
        @connection.stub(:scope).and_return("contact/invite")
        @connection.should_receive(:send_invite).with("m40363966002")
        get 'mxit_oauth', code: "123"
      end
    end

    context "profile" do
      let(:current_user_account){@current_user.account}

      it "returns sets and save profile information" do
        @connection.should_receive(:profile).and_return(:first_name => "Grant",
                                                        :last_name => "Speelman",
                                                        :mobile_number => "0821234567")
        get 'mxit_oauth', code: "123"
        current_user_account.real_name.should == "Grant Speelman"
        current_user_account.mobile_number.should == "0821234567"
      end

      it "returns usings mxit.im address if no email set" do
        @connection.should_receive(:profile).and_return(:user_id => "gman")
        get 'mxit_oauth', code: "123"
        current_user_account.email.should == "gman@mxit.im"
      end

      it "must not change values" do
        current_user_account.update_attributes(real_name: "Joe Barber",
                                               mobile_number: "0821234123",
                                               email: "joe.barber@mail.com")
        @connection.stub(:profile).and_return(:first_name => "Grant",
                                              :last_name => "Speelman",
                                              :mobile_number => "0821234567")
        get 'mxit_oauth', code: "123"
        current_user_account.reload
        current_user_account.real_name.should == "Joe Barber"
        current_user_account.mobile_number.should == "0821234123"
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
