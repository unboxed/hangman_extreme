require 'spec_helper'

describe 'winners' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
  end

  it "must show the last winners" do
    rating_winners = create_list(:winner,9, reason: "daily_rating")
    precision_winners = create_list(:winner,9, reason: "daily_precision")
    wins_winners = create_list(:winner,9, reason: "games_won_today")
    visit '/'
    click_link('winners')
    rating_winners.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('precision')
    precision_winners.each do |winner|
      page.should have_content(winner.name)
    end
    click_link('wins')
    wins_winners.each do |winner|
      page.should have_content(winner.name)
    end
  end

end