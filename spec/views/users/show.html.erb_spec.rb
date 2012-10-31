require 'spec_helper'

describe "users/show.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @user = assign(:user, stub_model(User, rank: 99))
    stub_template "_ranking_links.html.erb" => "<div>Ranking list</div>"
  end

  it "renders the ranking list" do
    render
    rendered.should have_content("Ranking list")
  end

  it "renders a list of games" do
    render
    rendered.should have_content("points")
    rendered.should have_content("rating")
    rendered.should have_content("precision")
  end

  context "Today scores" do

    it "must show points scored" do
      @user.should_receive(:daily_points).and_return("111")
      @user.should_receive(:rank).with(:daily_points).and_return(1)
      render
      rendered.should have_content("111")
      rendered.should have_content("1st")
    end

    it "must show rating" do
      @user.should_receive(:daily_rating).and_return("112")
      @user.should_receive(:rank).with(:daily_rating).and_return(2)
      render
      rendered.should have_content("112")
      rendered.should have_content("2nd")
    end

    it "must show precision" do
      @user.should_receive(:daily_precision).and_return("113")
      @user.should_receive(:rank).with(:daily_precision).and_return(3)
      render
      rendered.should have_content("113")
      rendered.should have_content("3rd")
    end

  end

  context "Weeks scores" do

    it "must show points scored" do
      @user.should_receive(:weekly_points).and_return("1111")
      @user.should_receive(:rank).with(:weekly_points).and_return(1)
      render
      rendered.should have_content("1111")
      rendered.should have_content("1st")
    end

    it "must show rating" do
      @user.should_receive(:weekly_rating).and_return("1121")
      @user.should_receive(:rank).with(:weekly_rating).and_return(2)
      render
      rendered.should have_content("1121")
      rendered.should have_content("2nd")
    end

    it "must show precision" do
      @user.should_receive(:weekly_precision).and_return("1131")
      @user.should_receive(:rank).with(:weekly_precision).and_return(3)
      render
      rendered.should have_content("1131")
      rendered.should have_content("3rd")
    end

  end

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

end
