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

  it "should add a new_game link to menu" do
    view.should_receive(:menu_item).with(anything,new_game_path,id: 'new_game')
    render
  end

  it "should have a view rank link on the menu" do
    view.should_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

  it "should have a feedback link on the menu" do
    args = {response_type: 'code',
            host: "test.host",
            protocol: 'http',
            client_id: ENV['MXIT_CLIENT_ID'],
            redirect_uri: mxit_oauth_users_url(host: "test.host"),
            scope: "profile/public profile/private",
            state: "feedback"}
    view.should_receive(:menu_item).with(anything,args,id: 'feedback')
    render
  end

  it "should have a authorise" do
    args = {response_type: 'code',
            host: "test.host",
            protocol: 'http',
            client_id: ENV['MXIT_CLIENT_ID'],
            redirect_uri: mxit_oauth_users_url(host: "test.host"),
            scope: "profile/public profile/private",
            state: "profile"}
    view.should_receive(:menu_item).with(anything,args,id: 'authorise')
    render
  end

  it "should have a buy more clue points link" do
    view.should_receive(:menu_item).with(anything,purchases_path,id: 'buy_clue_points')
    render
  end

  it "should have a link to redeem winnings if user have prize points" do
    view.should_receive(:menu_item).with(anything,redeem_winnings_path,id: 'redeem')
    render
  end

end