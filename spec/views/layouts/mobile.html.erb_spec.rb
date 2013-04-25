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
    render
    rendered.should have_link("Home", href: root_path)
  end

  it "should have a play game link" do
    render
    rendered.should have_link("Play", href: play_games_path)
  end

end