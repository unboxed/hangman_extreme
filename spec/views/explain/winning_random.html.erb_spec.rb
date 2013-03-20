require 'spec_helper'

describe "explain/winning_random.html.erb" do
  before(:each) do
    stub_template "_links.html.erb" => "<div>Links</div>"
  end

  it "renders the links" do
    render
    rendered.should have_content("Links")
  end

  it "must receive daily_random_games_required" do
    Winner.should_receive(:daily_random_games_required).and_return("DAILY_WINS")
    render
    rendered.should have_content("DAILY_WINS")
  end

  it "must receive weekly_random_games_required" do
    Winner.should_receive(:weekly_random_games_required).and_return("WEEKLY_WINS")
    render
    rendered.should have_content("WEEKLY_WINS")
  end

end
