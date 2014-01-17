require 'view_spec_helper'

describe "games/new" do
  before(:each) do
    assign(:game, stub_model(Game).as_new_record)
    @current_user_account = stub_model(UserAccount, id: 50)
    view.stub(:current_user_account).and_return(@current_user_account)
    view.stub(:mxit_request?)
  end

  it "renders new game form" do
    render
    rendered.should have_button('start_game')
  end
end
