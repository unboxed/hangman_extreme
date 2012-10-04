require 'spec_helper'

describe "winners/index.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @winners =
      assign(:winners, [
        stub_model(Winner, id: 100, name: "hello", amount: "123", reason: "daily_rating"),
        stub_model(Winner, id: 101, name: "goodbye")
      ])
    view.stub!(:paginate)
    view.stub!(:current_user).and_return(stub_model(User, id: 50))
  end

  it "renders a list of users" do
    render
    within("#winner_100") do
      rendered.should have_content("hello")
      rendered.should have_content("123")
      rendered.should have_content("hello")
      rendered.should have_content("hello")
    end
    within("#winner_101") do
      rendered.should have_content("goodbye")
    end
  end

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a rating link" do
    render
    rendered.should have_link("rating", href: winners_path(reason: 'daily_rating'))
  end

  it "should have a precision link" do
    render
    rendered.should have_link("precision", href: winners_path(reason: 'daily_precision'))
  end

  it "should have a wins link" do
    render
    rendered.should have_link("wins", href: winners_path(reason: 'games_won_today'))
  end

end
