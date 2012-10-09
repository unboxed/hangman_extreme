require 'spec_helper'

describe "users/index" do
  include ViewCapybaraRendered

  before(:each) do
    @users =
    assign(:users, [
      stub_model(User, id: 100, name: "hello", daily_rating: "123"),
      stub_model(User, id: 101, name: "goodbye", daily_rating: "345")
    ])
    view.stub!(:current_user).and_return(stub_model(User, id: 50))
    stub_template "_ranking_links.html.erb" => "<div>Ranking list</div>"
    assign(:send, "daily_rating")
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

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a view rank link" do
    render
    rendered.should have_link("view_rank", href: user_path(50))
  end


end