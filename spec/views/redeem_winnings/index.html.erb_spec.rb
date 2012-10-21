require 'spec_helper'

describe "redeem_winnings/index.html.erb" do

  before(:each) do
    @current_user = stub_model(User, id: 50)
    view.stub!(:current_user).and_return(@current_user)
  end

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a new_game link" do
    render
    rendered.should have_link("new_game", href: new_game_path)
  end

  it "should have a view rank link" do
    render
    rendered.should have_link("view_rank", href: user_path(50))
  end

  context "clue points" do

    it "must have equal clue points available to prize points" do
      @current_user.prize_points = 5
      render
      rendered.should have_content("#{@current_user.prize_points} clue points")
    end

    it "must have a maximum of 10 clue points available" do
      @current_user.prize_points = 15
      render
      rendered.should have_content("10 clue points")
    end

    it "must have a clue points link" do
      @current_user.prize_points = 5
      render
      rendered.should have_link("clue_points", href: new_redeem_winning_path(:prize_type => 'clue_points',
                                                                             :prize_amount => 5))
    end

    it "wont have a clue points link if no prize points" do
      @current_user.prize_points = 0
      render
      rendered.should_not have_link("clue_points")
    end

  end

  context "moola" do

    it "must have equal moola available to prize points" do
      @current_user.prize_points = 25
      render
      rendered.should have_content("#{@current_user.prize_points} moola")
    end

    it "must have a maximum of 100 moola available" do
      @current_user.prize_points = 115
      render
      rendered.should have_content("100 moola")
    end

    it "must have a moola link" do
      @current_user.prize_points = 22
      render
      rendered.should have_link("moola", href: new_redeem_winning_path(:prize_type => 'moola',
                                                                       :prize_amount => 22))
    end

    it "wont have a moola link if not enough prize points" do
      @current_user.prize_points = 19
      render
      rendered.should_not have_link("moola")
    end

  end

end
