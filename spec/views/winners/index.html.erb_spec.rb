require 'spec_helper'

describe "winners/index.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @winners =
      assign(:winners, [
        stub_model(Winner, id: 100, name: "hello", amount: "123", reason: "daily_rating"),
        stub_model(Winner, id: 101, name: "goodbye", amount: "124")
      ])
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

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a rating link" do
    render
    rendered.should have_link("daily_rating", href: winners_path(reason: 'rating'))
  end

  it "should have a precision link" do
    render
    rendered.should have_link("daily_precision", href: winners_path(reason: 'precision'))
  end

  it "should have a points link" do
    render
    rendered.should have_link("daily_points", href: winners_path(reason: 'points'))
  end

  it "should have a daily link" do
    render
    rendered.should have_link("daily_rating", href: winners_path(period: 'daily'))
  end

  it "should have a weekly link" do
    render
    rendered.should have_link("weekly_rating", href: winners_path(period: 'weekly'))
  end

  it "should have a monthly link" do
    render
    rendered.should have_link("monthly_rating", href: winners_path(period: 'monthly'))
  end

end
