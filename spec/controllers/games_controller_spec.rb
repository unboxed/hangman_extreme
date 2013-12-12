require 'spec_helper'

describe GamesController do

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

    def do_get_index
      get :index
    end

    it "assigns all completed games as @games" do
      game = create(:won_game)
      do_get_index
      assigns(:games).should eq([game])
    end

    it "assigns current game as @current_game" do
      game = create(:game, :user => @current_user)
      do_get_index
      assigns(:current_game).should eq(game)
    end

    it "renders successfully" do
      do_get_index
      response.should be_success
    end

  end

  describe "GET show" do

    before :each do
      @game = create(:game)
    end

    def do_get_show
      get :show, {:id => @game.to_param}
    end

    it "assigns the requested game as @game" do
      do_get_show
      assigns(:game).should eq(@game)
    end

    it "renders successfully" do
      do_get_show
      response.should be_success
    end

  end

  describe "GET show_clue" do

    before :each do
      @game = create(:game)
      get :show_clue, {:id => @game.to_param}
    end

    it "assigns the requested game as @game" do
      assigns(:game).should eq(@game)
    end

    it "renders successfully" do
      response.should be_success
    end

  end

  describe "POST reveal_clue" do

    before :each do
      @game = create(:game, user: @current_user)
    end

    def do_post_reveal_clue
      post :reveal_clue, {:id => @game.to_param}
    end

    it "must show clue" do
      @current_user.update_attribute(:credits, 1)
      expect {
        do_post_reveal_clue
      }.to change { @game.reload; @game.clue_revealed }
    end

    it "wont show clue" do
      @current_user.update_attribute(:credits, 0)
      do_post_reveal_clue
      response.should redirect_to(purchases_path)
      flash[:alert].should_not be_blank
    end

    it "assigns the requested game as @game" do
      do_post_reveal_clue
      assigns(:game).should eq(@game)
    end

    it "redirect to show" do
      do_post_reveal_clue
      response.should redirect_to(action: 'show')
    end

  end

  describe "GET play_letter" do

    before :each do
      @game = create(:game, choices: "a", user: @current_user)
    end

    def do_get_play_letter
      get :play_letter, :id => @game.to_param, :letter => "g"
    end

    it "assigns the requested game as @game" do
      do_get_play_letter
      assigns(:game).should eq(@game)
      @game.reload
      @game.choices.should include("g")
    end

    it "render the show template" do
      do_get_play_letter
      response.should redirect_to(@game)
    end

    it "render adds a flash message if rank increases" do
      create(:user, daily_rating: 1)
      @game = create(:game, word: "game", choices: "ame", user: @current_user)
      expect {
        do_get_play_letter
      }.to change { @current_user.reload; @current_user.daily_rating }
      flash[:notice].should_not be_blank
    end

    it "Should not get Bookworm Badge if a 10 letter word won and used a clue" do 
      @game = create(:game, word: "television", choices: "telviso", user: @current_user)
      get :show_clue, {:id => @game.to_param}
      post :reveal_clue, {:id => @game.to_param}
      get :play_letter, :id => @game.to_param, :letter => "n"
      flash[:notice].should_not have_content "Congratulations"
    end 

    it "First 10 letter word won with no clue receives Bookworm Badge" do 
      @game = create(:game, word: "television", choices: "telviso", user: @current_user)
      get :play_letter, :id => @game.to_param, :letter => "n"
      flash[:notice].should have_content "Congratulations"
    end 

    it "Should not get Bookworm Badge for <9 letter word won" do
      @game = create(:game, word:"airport", choices: "airpo", user: @current_user)
      get :play_letter, :id => @game.to_param, :letter => "t"
      flash[:notice].should_not have_content "Congratulations"
    end 

    it "Should not receive Bookworm Badge twice" do
      create(:badge, name: 'Bookworm', user: @current_user)
      @game = create(:game, word: "television", choices: "telviso", user: @current_user)
      get :play_letter, :id => @game.to_param, :letter => "n"
      flash[:notice].should_not have_content "Congratulations"
    end 

    it "Should give Clueless Badge if 5 clues where used" do
      create(:won_game, word: "duck", clue_revealed: true, user: @current_user)
      create(:won_game, word: "duck", clue_revealed: true, user: @current_user)
      create(:won_game, word: "duck", clue_revealed: true, user: @current_user)
      create(:won_game, word: "duck", clue_revealed: true, user: @current_user)
      @game = create(:game, word: "duck", choices: "duc", clue_revealed: true, user: @current_user)
      get :play_letter, :id => @game.to_param, :letter => "k"
      flash[:notice].should have_content "Congratulations"
    end

    it "Should not give Clueless Badge twice" do
      create(:badge, name: 'Clueless', user: @current_user)
      @game = create(:game, word: "duck", choices: "duc", clue_revealed: true, user: @current_user)
      get :play_letter, :id => @game.to_param, :letter => "k"
      flash[:notice].should_not have_content "Congratulations"
    end 

    it "Should not give Clueless Badge if 5 clues were not used in a row" do
      create(:won_game, word: "duck", clue_revealed: true, user: @current_user)
      create(:won_game, word: "duck", clue_revealed: true, user: @current_user)
      create(:won_game, word: "duck", clue_revealed: true, user: @current_user)
      create(:won_game, word: "duck", user: @current_user)
      create(:won_game, word: "duck", clue_revealed: true, user: @current_user)
      @game = create(:game, word: "duck", choices: "duc", clue_revealed: true, user: @current_user)
      get :play_letter, :id => @game.to_param, :letter => "k"
      flash[:notice].should_not have_content "Congratulations" 
    end

    it "Should give Brainey Badge if 10 words were played in a row without using clues" do 
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      @game = create(:game, word: "meaow", choices: "meao", user: @current_user)
      get :play_letter, :id => @game.to_param, :letter => "w"
      flash[:notice].should have_content "Congratulations" 
    end 

    it "Should not give the Brainey Badge twice" do
      create(:badge, name: 'Brainey', user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      create(:won_game, word: "meaow", user: @current_user)
      @game = create(:game, word: "meaow", choices: "meao", user: @current_user)
      get :play_letter, :id => @game.to_param, :letter => "w"
      flash[:notice].should_not have_content "Congratulations"
    end 
  end

  describe "GET new" do

    def do_get_new
      get :new
    end

    it "assigns a new game as @game" do
      do_get_new
      assigns(:game).should be_a_new(Game)
    end

    it "must be successful" do
      do_get_new
      response.should be_success
    end

    it "redirects to purchase_transaction_path if no more credits" do
      @current_user.update_attribute(:credits,0)
      do_get_new
      response.should redirect_to(purchases_path)
      flash[:alert].should_not be_blank
    end

  end

  describe "GET play" do

    def do_get_play
      get :play
    end

    it "assigns redirects to new game path" do
      do_get_play
      response.should redirect_to(new_game_path)
    end

    it "assigns redirects to current game path" do
      game = create(:game, user: @current_user)
      do_get_play
      response.should redirect_to(game)
    end

  end

# update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  describe "POST create" do

    def do_create
      post :create,
           :game => valid_attributes
    end

    describe "with valid params" do

      it "creates a new Game" do
        expect {
          do_create
        }.to change(Game, :count).by(1)
      end

      it "reduces the users credits" do
        expect {
          do_create
        }.to change{@current_user.reload; @current_user.credits}.by(-1)
      end

      it "assigns a newly created game as @game" do
        do_create
        assigns(:game).should be_a(Game)
        assigns(:game).user.should == @current_user
        assigns(:game).should be_persisted
      end

      it "redirects to the created game" do
        do_create
        response.should redirect_to(Game.last)
      end
    end

    describe "with invalid params" do

      before :each do
        # Trigger the behavior that occurs when invalid params are submitted
        Game.any_instance.stub(:save).and_return(false)
      end

      it "assigns a newly created but unsaved game as @game" do
        do_create
        assigns(:game).should be_a_new(Game)
      end

      it "redirects to index" do
        do_create
        response.should redirect_to(Game)
      end

      it "sets an alert message" do
        do_create
        flash[:alert].should_not be_blank
      end

    end

  end

end
