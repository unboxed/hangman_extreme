require 'spec_helper'

describe WinnersController do

  before :each do
    @current_user = create(:user)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can(:manage, :all)
    controller.stub(:current_ability).and_return(@ability)
    controller.stub(:current_user).and_return(@current_user)
    controller.stub(:send_stats)
  end

  describe "GET index" do

    def do_get_index(params = {})
      get :index, params
    end

    it "assigns all winners as @winners" do
      create(:winner, end_of_period_on: Date.yesterday, period: 'daily', reason: 'rating')
      do_get_index
      assigns(:winners).should include(Winner.last)
    end

    it "renders the application layout" do
      do_get_index
      response.should render_template("layouts/application")
    end

  end

end
