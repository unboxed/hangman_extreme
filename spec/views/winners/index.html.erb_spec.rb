require 'spec_helper'

describe "winners/index.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @winners =
      assign(:winners, [
        stub_model(Winner, id: 100, name: "hello", amount: "123", reason: "daily_rating"),
        stub_model(Winner, id: 101, name: "goodbye", amount: "124")
      ])
    @current_user = stub_model(User, id: 33)
    view.stub(:current_user).and_return(@current_user)
    view.stub(:mxit_request?).and_return(true)
    view.stub(:menu_item)
    view.stub(:guest?)
  end

  it "renders a list of users" do
    render
    within("#winner_100") do
      rendered.should have_content("hello")
      rendered.should have_content("123")
    end
    within("#winner_101") do
      rendered.should have_content("goodbye")
      rendered.should have_content("124")
    end
  end

  it "should have a view rank link if not guest" do
    view.stub(:guest?).and_return(false)
    view.should_receive(:menu_item).with(anything,user_path(33),id: 'view_rank')
    render
  end

  it "wont have a view rank link if guest" do
    view.stub(:guest?).and_return(true)
    view.should_not_receive(:menu_item).with(anything,user_path(33),id: 'view_rank')
    render
  end

  it "should have a rating link" do
    render
    rendered.should have_link("daily_rating", href: winners_path(reason: 'rating'))
  end

  it "should have a score link" do
    render
    rendered.should have_link("daily_streak", href: winners_path(reason: 'streak'))
  end

  it "should have a daily link" do
    render
    rendered.should have_link("daily_rating", href: winners_path(period: 'daily'))
  end

  it "should have a weekly link" do
    render
    rendered.should have_link("weekly_rating", href: winners_path(period: 'weekly'))
  end

end
