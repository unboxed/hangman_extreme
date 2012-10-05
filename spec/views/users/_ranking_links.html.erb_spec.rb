require 'spec_helper'

describe "users/_ranking_links.html.erb" do
  include ViewCapybaraRendered

  it "must have daily,weekly and monthly links" do
    render :partial => "users/ranking_links"
    rendered.should have_link("daily_rating", :href => users_path(period: 'daily'))
    rendered.should have_link("weekly_rating", :href => users_path(period: 'weekly'))
    rendered.should have_link("monthly_rating", :href => users_path(period: 'monthly'))
  end

  it "must have wins,rating and precision links" do
    render :partial => "users/ranking_links"
    rendered.should have_link("daily_wins", :href => users_path(rank_by: 'wins'))
    rendered.should have_link("daily_rating", :href => users_path(rank_by: 'rating'))
    rendered.should have_link("daily_precision", :href => users_path(rank_by: 'precision'))
  end


end
