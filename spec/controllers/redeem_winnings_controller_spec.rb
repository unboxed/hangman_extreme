require 'spec_helper'

describe RedeemWinningsController do

  before :each do
    @current_user = create(:user)
    controller.stub(:current_user).and_return(@current_user)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "renders the application layout" do
      get 'index'
      response.should render_template("layouts/application")
    end
  end

end
