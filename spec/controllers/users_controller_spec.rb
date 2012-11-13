require 'spec_helper'

describe UsersController do

  context "functionality" do

    before :each do
      @current_user = create(:user)
      @ability = Object.new
      @ability.extend(CanCan::Ability)
      @ability.can(:manage, :all)
      controller.stub(:current_ability).and_return(@ability)
      controller.stub(:current_user).and_return(@current_user)
    end

    describe "GET 'show'" do
      it "returns http success" do
        get 'show'
        response.should be_success
      end

      it "assigns the requested user as @user" do
        get 'show'
        assigns(:user).should eq(@current_user)
      end

    end

    describe "GET 'mxit_oauth'" do

      before :each do
        @connection = mock('MxitApi', access_token: "123", profile: {}, scope: "profile")
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
        response.should redirect_to(profile_users_path)
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

        it "returns sets and save profile information" do
          @connection.should_receive(:profile).and_return(:first_name => "Grant",
                                                          :last_name => "Speelman",
                                                          :mobile_number => "0821234567")
          @current_user.should_receive(:save)
          get 'mxit_oauth', code: "123"
          @current_user.real_name.should == "Grant Speelman"
          @current_user.mobile_number.should == "0821234567"
        end

        it "returns usings mxit.im address if no email set" do
          @connection.should_receive(:profile).and_return(:user_id => "gman")
          @current_user.should_receive(:save)
          get 'mxit_oauth', code: "123"
          @current_user.email.should == "gman@mxit.im"
        end

        it "must not change values" do
          @current_user.real_name = "Joe Barber"
          @current_user.mobile_number = "0821234123"
          @current_user.email = "joe.barber@mail.com"
          @connection.stub(:profile).and_return(:first_name => "Grant",
                                                :last_name => "Speelman",
                                                :mobile_number => "0821234567")
          @current_user.stub(:save)
          get 'mxit_oauth', code: "123"
          @current_user.real_name.should == "Joe Barber"
          @current_user.mobile_number.should == "0821234123"
        end

      end


    end

    describe "GET index" do

      def do_get_index(params = {})
        get :index, params
      end

      ['daily','weekly'].each do |period|
        ['score','rating', 'precision'].each do |ranking|
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

      it "renders the application layout" do
        do_get_index
        response.should render_template("layouts/application")
      end

    end

    describe "GET stats" do

      it "renders the application layout" do
        User.stub(:cohort_array).and_return([[1,1,1,1,1,1]])
        Game.stub(:cohort_array).and_return([[2,2,2,2,2]])
        Winner.stub(:cohort_array).and_return([[2,2,2,2,2]])
        PurchaseTransaction.stub(:cohort_array).and_return([[2,2,2,2,2]])
        get :stats
        response.should render_template("layouts/application")
      end

    end

    describe "PUT update" do

      before :each do
        @user = create(:user)
      end

      def do_update
        put :update, :user => {'real_name' => 'params'}, :id => @user.id
      end

      describe "with valid params" do

        it "updates the requested user" do
          User.any_instance.should_receive(:update_attributes).with({'real_name' => 'params'}, as: 'user').and_return(true)
          do_update
        end

        it "assigns the requested user as @user" do
          do_update
          assigns(:user).should eq(@user)
        end

        it "redirects to the profile page" do
          do_update
          response.should redirect_to(profile_users_path)
        end

        it "sets an notice" do
          do_update
          flash[:notice].should  == 'Profile was successfully updated.'
        end

      end

      describe "with invalid params" do

        before :each do
          # Trigger the behavior that occurs when invalid params are submitted
          User.any_instance.stub(:save).and_return(false)
        end

        it "sets an alert" do
          do_update
          flash[:alert].should_not be_blank
        end

        it "assigns the requested user as @user" do
          do_update
          assigns(:user).should eq(@user)
        end

        it "redirects to the profile page" do
          do_update
          response.should redirect_to(profile_users_path)
        end

      end
    end

  end

end
