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

    ['daily_rating','daily_precision', 'games_won_today'].each do |reason|
      it "assigns all #{reason} winners as @winners" do
        winner = create(:winner, reason: reason)
        do_get_index :reason => reason
        assigns(:winners).should include(winner)
      end
    end

    it "renders the application layout" do
      do_get_index
      response.should render_template("layouts/application")
    end

  end

end
