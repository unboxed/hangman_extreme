require 'spec_helper'

describe 'winners' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
  end

  it "must show the last winners" do
    rating_winners = create_list(:winner,9, reason: "rating", period: 'daily')
    precision_winners = create_list(:winner,9, reason: "precision", period: 'daily')
    points_winners = create_list(:winner,9, reason: "points", period: 'daily')
    visit '/'
    click_link('rank')
    click_link('winners')
    rating_winners.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('precision')
    precision_winners.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('points')
    points_winners.each do |winner|
      page.should have_content(winner.name)
    end
  end

  it "must show the weekly winners" do
    rating_winners = create_list(:winner,9, reason: "rating", period: 'weekly')
    precision_winners = create_list(:winner,9, reason: "precision", period: 'weekly')
    points_winners = create_list(:winner,9, reason: "points", period: 'weekly')
    visit '/'
    click_link('rank')
    click_link('winners')
    click_link('weekly')
    rating_winners.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('precision')
    precision_winners.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('points')
    points_winners.each do |winner|
      page.should have_content(winner.name)
    end
  end

end