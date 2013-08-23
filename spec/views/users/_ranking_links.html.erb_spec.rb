require 'spec_helper'

describe "users/_ranking_links.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    view.stub(:menu_item)
    view.stub(:mxit_request?).and_return(true)
  end

  it "must have daily and weekly links" do
    render :partial => "users/ranking_links"
    rendered.should have_link("daily_rating", :href => users_path(period: 'daily'))
    rendered.should have_link("weekly_rating", :href => users_path(period: 'weekly'))
  end

  it "must have streak and rating links" do
    render :partial => "users/ranking_links"
    rendered.should have_link("daily_streak", :href => users_path(rank_by: 'streak'))
    rendered.should have_link("daily_rating", :href => users_path(rank_by: 'rating'))
  end

  it "must have a link to explain the scoring on menu" do
    view.should_receive(:menu_item).with(anything,explain_path(action: 'scoring_categories'),id: 'scoring_categories')
    render :partial => "users/ranking_links"
  end

  it "must have a link to the winners page on menu" do
    view.should_receive(:menu_item).with(anything,winners_path,id: 'winners')
    render :partial => "users/ranking_links"
  end

end
