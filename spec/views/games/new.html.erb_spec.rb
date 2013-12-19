require 'view_spec_helper'

describe "games/new" do
  before(:each) do
    assign(:game, stub_model(Game).as_new_record)
    @current_user = stub_model(User, id: 50)
    view.stub(:current_user).and_return(@current_user)
  end

  it "renders new game form" do
    render
    rendered.should have_button('start_game')
  end
end
