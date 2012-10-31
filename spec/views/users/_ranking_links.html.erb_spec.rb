require 'spec_helper'

describe "users/_ranking_links.html.erb" do
  include ViewCapybaraRendered

  it "must have daily,weekly and monthly links" do
    render :partial => "users/ranking_links"
    rendered.should have_link("daily_rating", :href => users_path(period: 'daily'))
    rendered.should have_link("weekly_rating", :href => users_path(period: 'weekly'))
  end

  it "must have points,rating and precision links" do
    render :partial => "users/ranking_links"
    rendered.should have_link("daily_points", :href => users_path(rank_by: 'points'))
    rendered.should have_link("daily_rating", :href => users_path(rank_by: 'rating'))
    rendered.should have_link("daily_precision", :href => users_path(rank_by: 'precision'))
  end

  it "must have a link to explain the scoring" do
    render :partial => "users/ranking_links"
    rendered.should have_link("scoring_categories", :href => explain_path(action: 'scoring_categories'))
  end

  it "must have a link to the winners page" do
    render :partial => "users/ranking_links"
    rendered.should have_link("winners", :href => winners_path)
  end


end
