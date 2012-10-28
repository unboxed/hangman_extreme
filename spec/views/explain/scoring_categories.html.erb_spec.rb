require 'spec_helper'

describe "explain/scoring_categories.html.erb" do

  before(:each) do
    view.stub!(:current_user).and_return(stub_model(User, id: 44))
  end

  it "must have a link to points" do
    render
    rendered.should have_link("points", href: explain_path(action: 'points'))
  end

  it "must have a link to rating" do
    render
    rendered.should have_link("rating", href: explain_path(action: 'rating'))
  end

  it "must have a link to precision" do
    render
    rendered.should have_link("precision", href: explain_path(action: 'precision'))
  end

  it "must have a link to streak" do
    render
    rendered.should have_link("winning_streak", href: explain_path(action: 'winning_streak'))
  end

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a view rank link" do
    render
    rendered.should have_link("view_rank", href: user_path(44))
  end

end
