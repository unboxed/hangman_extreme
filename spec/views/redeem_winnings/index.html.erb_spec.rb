require 'spec_helper'

describe "redeem_winnings/index.html.erb" do

  before(:each) do
    @current_user = stub_model(User, id: 50)
    view.stub!(:current_user).and_return(@current_user)
  end

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a new_game link" do
    render
    rendered.should have_link("new_game", href: new_game_path)
  end

  it "should have a view rank link" do
    render
    rendered.should have_link("view_rank", href: user_path(50))
  end

end
