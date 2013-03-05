require 'spec_helper'

describe "explain/scoring_categories.html.erb" do

  before(:each) do
    view.stub!(:current_user).and_return(stub_model(User, id: 44))
    view.stub!(:menu_item)
  end

  it "must have a link to score" do
    render
    rendered.should have_link("score", href: explain_path(action: 'score'))
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

  it "should have a home page link on menu" do
    view.should_receive(:menu_item).with(anything,'/',id: 'root_page')
    render
  end

  it "should have a view rank link" do
    view.should_receive(:menu_item).with(anything,user_path(44),id: 'view_rank')
    render
  end

  it "must have a link to payouts" do
    view.should_receive(:menu_item).with(anything,explain_path(action: 'payouts'),id: 'payouts')
    render
  end

end
