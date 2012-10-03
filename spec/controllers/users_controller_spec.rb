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
        token_body = %&{
                         "access_token":"c71219af53f5409e9d1db61db8a08248",
                         "token_type":"bearer",
                         "expires_in":3600,
                         "refresh_token":"7f4b56bda11e4f7ba84c9e35c76b7aea",
                         "scope":"message"
                       }&
        stub_request(:post, "http://auth.mxit.com/token").
          with(:body => {"code"=>"123", "grant_type"=>"authorization_code", "redirect_uri"=>"http://test.host/users/profile"},
               :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'92', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => token_body, :headers => {})

        body = %&{
                    "DisplayName":"String content",
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
        stub_request(:get, "http://auth.mxit.com/user/profile").
          with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Bearer c71219af53f5409e9d1db61db8a08248', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => body, :headers => {})
      end

      it "returns sets and save profile information" do
        @current_user.should_receive(:save)
        get 'mxit_oauth', code: "123"
        @current_user.real_name.should == "Grant Speelman"
        @current_user.mobile_number.should == "0821234567"
      end

      it "returns redirects to profile page" do
        get 'mxit_oauth', code: "123"
        response.should redirect_to(profile_users_path)
      end

      it "returns redirects to root page if token request fails" do
        stub_request(:post, "http://auth.mxit.com/token").to_return(:status => 401, :body => '', :headers => {})
        get 'mxit_oauth', code: "123"
        response.should redirect_to(profile_users_path)
        flash[:alert].should_not be_blank
      end

      it "returns redirects to root page if auth fails" do
        stub_request(:get, "http://auth.mxit.com/user/profile").to_return(:status => 401, :body => '', :headers => {})
        get 'mxit_oauth', code: "123"
        response.should redirect_to(profile_users_path)
        flash[:alert].should_not be_blank
      end

      it "returns redirects to root page if no code" do
        get 'mxit_oauth'
        response.should redirect_to(profile_users_path)
        flash[:alert].should_not be_blank
      end

    end

    describe "GET index" do

      def do_get_index(params = {})
        get :index, params
      end

      ['daily','weekly', 'monthly'].each do |period|
        it "assigns all top #{period} wins users as @users" do
          user = create(:user)
          do_get_index :rank_by => 'wins', :period => period
          assigns(:users).should include(user)
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
