require 'spec_helper'

describe "layouts/mobile" do
  include ViewCapybaraRendered

  before(:each) do
    @current_user = stub_model(User, id: 50)
    view.stub!(:current_user).and_return(@current_user)
    view.stub!(:current_page?).and_return(false)
    view.stub!(:smaato_ad).and_return(false)
    view.stub!(:mxit_request?).and_return(false)
  end

  it "should have a home link" do
    view.should_receive(:current_page?).with(root_path).and_return(false)
    render
    rendered.should have_link("home", href: root_path)
  end

  it "wont have a home link if current_page" do
    view.should_receive(:current_page?).with(root_path).and_return(true)
    render
    rendered.should_not have_link("home", href: root_path)
  end

  it "should have a play game link" do
    view.stub!(:params).and_return(action: 'index')
    render
    rendered.should have_link("play_game", href: play_games_path)
  end

  it "wont have a new game link if not index page" do
    view.stub!(:params).and_return(action: 'other')
    render
    rendered.should_not have_link("play_game", href: play_games_path)
  end

end