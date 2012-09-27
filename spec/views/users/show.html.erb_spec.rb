require 'spec_helper'

describe "users/show.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @user = assign(:user, stub_model(User, rank: 1,
                                           games_won_this_week: 1,
                                           weekly_rating: 20,
                                           weekly_precision: 20))
  end

  it "renders a list of games" do
    render
    rendered.should have_content("Games Won")
    rendered.should have_content("Rating")
    rendered.should have_content("Precision")
  end

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a link to top weekly users" do
    render
    rendered.should have_link("view_top_week_users", href: users_path(order: 'top_week'))
  end

  it "should have a link to top monthly users" do
    render
    rendered.should have_link("view_top_month_users", href: users_path(order: 'top_month'))
  end

end
