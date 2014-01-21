require 'view_spec_helper'

describe "users/index" do

  before(:each) do
    @users =
    assign(:users, [
      stub_model(User, id: 100, name: "hello", daily_rating: "123"),
      stub_model(User, id: 101, name: "goodbye", daily_rating: "345")
    ])
    view.stub(:mxit_request?).and_return(true)
    view.stub(:current_user).and_return(stub_model(User, id: 50))
    stub_template "_ranking_links.html.erb" => "<div>Ranking list</div>"
    assign(:send, "daily_rating")
    view.stub(:menu_item)
    view.stub(:guest?)
  end

  it "renders the ranking list" do
    render
    rendered.should have_content("Ranking list")
  end

  it "renders a list of users" do
    render
    within("#user_100") do
      rendered.should have_content("hello")
      rendered.should have_content("123")
    end
    within("#user_101") do
      rendered.should have_content("goodbye")
      rendered.should have_content("345")
    end
  end

  it "should have a view rank link if not guest" do
    view.stub(:guest?).and_return(false)
    view.should_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

  it "wont have a view rank link if guest" do
    view.stub(:guest?).and_return(true)
    view.should_not_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

end
