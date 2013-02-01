require 'spec_helper'

describe "redeem_winnings/new.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @redeem_winning = assign(:redeem_winning,stub_model(RedeemWinning))
    @redeem_winning.prize_type = 'clue_points'
  end

  it "renders should have correct fields" do
    render
    within("form") do
      rendered.should have_css('input#redeem_winning_prize_type')
      rendered.should have_css('input#redeem_winning_prize_amount')
      rendered.should have_css('input#redeem_winning_state')
    end
  end

  it "renders a submit button" do
    render
    rendered.should have_button('submit')
  end

  it "should have a home link" do
    render
    rendered.should have_link("cancel", href: redeem_winnings_path)
  end

  it "should render with vodago_airtime prize type" do
    @redeem_winning.prize_type = 'vodago_airtime'
    render
    rendered.should have_link("cancel", href: redeem_winnings_path)
  end

  it "should render with mxit money prize type" do
    @redeem_winning.prize_amount = 101
    @redeem_winning.prize_type = 'mxit_money'
    render
    rendered.should have_content("R1.01")
  end

end
