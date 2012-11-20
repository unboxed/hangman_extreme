require 'spec_helper'

describe "games/index" do
  include ViewCapybaraRendered

  before(:each) do
    @games =
    assign(:games, [
      stub_model(Game, id: 100, done?: true, hangman_text: "hello", score: 100),
      stub_model(Game, id: 101, done?: false, hangman_text: "goodbye", score: 500)
    ])
    @current_user = stub_model(User, id: 50)
    view.stub!(:current_user).and_return(@current_user)
    view.stub!(:menu_item)
  end

  it "renders a list of games" do
    render
    within("#game_100") do
      rendered.should have_content("hello")
      rendered.should have_content("100")
    end
    within("#game_101") do
      rendered.should have_content("goodbye")
      rendered.should have_content("500")
    end
  end

  it "renders a actions of games" do
    render
    within("#game_100") do
      rendered.should have_link("show_game_100", href: game_path(100))
    end
    within("#game_101") do
      rendered.should have_link("show_game_101", href: game_path(101))
    end
  end

  it "must add a continue_game link to menu" do
    assign(:current_game, stub_model(Game, id: 111))
    view.should_receive(:menu_item).with(anything,game_path(111),id: 'continue_game')
    render
    view.stub!(:mxit_request?).and_return(true)
  end

  it "wont add a new_game link to menu if current_game exists" do
    assign(:current_game, stub_model(Game, id: 111))
    view.should_not_receive(:menu_item).with(anything,new_game_path,id: 'new_game')
    render
  end

  it "must add a new_game link to menu" do
    view.should_receive(:menu_item).with(anything,new_game_path,id: 'new_game')
    render
  end

  it "must have a view rank link on the menu" do
    view.should_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

  it "must have a feedback link on the menu" do
    args = {response_type: 'code',
            host: "test.host",
            protocol: 'http',
            client_id: ENV['MXIT_CLIENT_ID'],
            redirect_uri: mxit_oauth_users_url(host: "test.host"),
            scope: "profile/public profile/private",
            state: "feedback"}
    view.should_receive(:menu_item).with(anything,mxit_authorise_url(args),id: 'feedback')
    render
  end

  it "must have a authorise" do
    args = {response_type: 'code',
            host: "test.host",
            protocol: 'http',
            client_id: ENV['MXIT_CLIENT_ID'],
            redirect_uri: mxit_oauth_users_url(host: "test.host"),
            scope: "profile/public profile/private",
            state: "profile"}
    view.should_receive(:menu_item).with(anything,mxit_authorise_url(args),id: 'authorise')
    render
  end

  it "must have a buy more clue points link" do
    view.should_receive(:menu_item).with(anything,purchases_path,id: 'buy_clue_points')
    render
  end

  it "must have a link to redeem winnings if user have prize points" do
    view.should_receive(:menu_item).with(anything,redeem_winnings_path,id: 'redeem')
    render
  end

  it "should have a share link if mxit request" do
    render
    rendered.should have_link("Share with your friends")
  end

  it "wont have a share link if not mxit request" do
    view.stub!(:mxit_request?).and_return(false)
    render
    rendered.should_not have_link("Share with your friends")
  end

  it "should have a view winners link" do
    render
    rendered.should have_link("winners", href: winners_path)
  end

end