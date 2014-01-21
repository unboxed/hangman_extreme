require 'view_spec_helper'

describe "explain/scoring_categories.html.erb" do

  before(:each) do
    view.stub(:mxit_request?).and_return(true)
    view.stub(:current_user).and_return(stub_model(User, id: 44))
    view.stub(:menu_item)
    view.stub(:guest?)
  end

  it "must have a link to rating" do
    render
    rendered.should have_link('rating', href: explain_path(action: 'rating'))
  end

  it "must have a link to streak" do
    render
    rendered.should have_link('streak', href: explain_path(action: 'winning_streak'))
  end

  it "must have a link to random" do
    render
    rendered.should have_link('random', href: explain_path(action: 'winning_random'))
  end

  it "should have a view rank link if not guest" do
    view.stub(:guest?).and_return(false)
    view.should_receive(:menu_item).with(anything,user_path(44),id: 'view_rank')
    render
  end

  it "wont have a view rank link if guest" do
    view.stub(:guest?).and_return(true)
    view.should_not_receive(:menu_item).with(anything,user_path(44),id: 'view_rank')
    render
  end

  it "must have a link to payouts" do
    view.should_receive(:menu_item).with(anything,explain_path(action: 'payouts'),id: 'payouts')
    render
  end

end
