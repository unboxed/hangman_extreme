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

end
