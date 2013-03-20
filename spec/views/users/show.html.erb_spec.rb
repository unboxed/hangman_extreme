require 'spec_helper'

describe "users/show.html.erb" do

  before(:each) do
    @user = mock("User", monthly_score: "a", monthly_score_rank: "a")
    stub_template "_ranking_links.html.erb" => "<div>Ranking list</div>"
    Winner.stub!(:winning_periods).and_return(["monthly"])
    Winner.stub!(:winning_reasons).and_return(["score"])
  end

  it "renders the ranking list partial" do
    render
    rendered.should have_content("Ranking list")
  end

  it "renders a the periods" do
    Winner.should_receive(:winning_periods).and_return(["monthly"])
    render
    rendered.should have_content("monthly")
  end

  it "renders the reasons" do
    Winner.should_receive(:winning_reasons).and_return(["score"])
    render
    rendered.should have_content("score")
  end

  it "must show score and rank" do
    @user.should_receive(:monthly_score).and_return("111")
    @user.should_receive(:monthly_score_rank).and_return("1st")
    render
    rendered.should have_content("111")
    rendered.should have_content("1st")
  end

  it "should have a home page link" do
    view.should_receive(:menu_item).with(anything,root_path,id: 'root_page')
    render
  end

end
