require 'spec_helper'

describe RedeemWinningsController do

  before :each do
    @current_user = create(:user)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can(:manage, :all)
    controller.stub(:current_ability).and_return(@ability)
    controller.stub(:current_user).and_return(@current_user)
    controller.stub(:send_stats)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "renders successfully" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET new" do

    it "redirects to index if no prize_type" do
      get :new
      response.should redirect_to(action: 'index')
    end

    it "assigns a new clue_points redeem_winning as @redeem_winning" do
      @current_user.prize_points = 9
      get :new, :prize_type => "clue_points", :prize_amount => "9"
      assigns(:redeem_winning).should be_a_new(RedeemWinning)
      assigns(:redeem_winning).prize_type.should == "clue_points"
      assigns(:redeem_winning).prize_amount.should == 9
      assigns(:redeem_winning).state.should == 'pending'
    end

  end

  # update the return value of this method accordingly.
  def valid_attributes
    {prize_type: 'clue_points', state: 'paid', prize_amount: 10}
  end

  describe "POST create" do

    def do_create
      @current_user.increment!(:prize_points,valid_attributes[:prize_amount])
      post :create, :redeem_winning => valid_attributes
    end

    describe "with valid params" do

      before :each do
        @current_user.increment!(:prize_points,11)
      end

      it "creates a new redeem winning" do
        expect {
          do_create
        }.to change(RedeemWinning, :count).by(1)
      end

      it "assigns a newly created redeem winning as @redeem_winning" do
        do_create
        assigns(:redeem_winning).should be_a(RedeemWinning)
        assigns(:redeem_winning).user.should == @current_user
        assigns(:redeem_winning).should be_persisted
      end

      it "redirects to index" do
        do_create
        response.should redirect_to(action: 'index')
      end

      it "sets an notice message" do
        do_create
        flash[:notice].should_not be_blank
      end

    end

    describe "with invalid params" do

      before :each do
        # Trigger the behavior that occurs when invalid params are submitted
        RedeemWinning.any_instance.stub(:save!).and_raise("error")
      end

      it "assigns a newly created but unsaved game as @redeem_winning" do
        do_create
        assigns(:redeem_winning).should be_a_new(RedeemWinning)
      end

      it "redirects to index" do
        do_create
        response.should redirect_to(action: 'index')
      end

      it "sets an alert message" do
        do_create
        flash[:alert].should_not be_blank
      end

    end
  end

end
