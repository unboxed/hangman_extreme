require 'spec_helper'

describe UserAccountsController do
  before :each do
    @current_user = create(:user)
    @current_user_account = @current_user.account
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
      assigns(:user_account).should eq(@current_user_account)
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "PUT update" do
    def do_update
      put :update, :user_account => {'real_name' => 'params'}
    end

    context "with valid params" do
      it "updates the requested user" do
        UserAccount.any_instance.should_receive(:update_attributes).with({'real_name' => 'params'}).and_return(true)
        do_update
      end

      it "assigns the requested user as @user" do
        do_update
        assigns(:user_account).should eq(@current_user_account)
      end

      it "redirects to the profile page" do
        do_update
        response.should redirect_to(user_accounts_path)
      end

      it "sets an notice" do
        do_update
        flash[:notice].should == 'Profile was successfully updated.'
      end

      context "with invalid params" do
        before :each do
          # Trigger the behavior that occurs when invalid params are submitted
          UserAccount.any_instance.stub(:save).and_return(false)
        end

        it "sets an alert" do
          do_update
          flash[:alert].should_not be_blank
        end

        it "assigns the requested user as @user" do
          do_update
          assigns(:user_account).should eq(@current_user_account)
        end

        it "redirects to the profile page" do
          do_update
          response.should redirect_to(user_accounts_path)
        end
      end
    end
  end
end
