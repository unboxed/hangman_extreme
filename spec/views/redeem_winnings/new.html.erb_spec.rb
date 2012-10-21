require 'spec_helper'

describe "redeem_winnings/new.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @redeem_winning = assign(:redeem_winning,stub_model(RedeemWinning))
    render
  end

  it "renders should have correct fields" do
    within("form") do
      rendered.should have_css('input#redeem_winning_prize_type')
      rendered.should have_css('input#redeem_winning_prize_amount')
      rendered.should have_css('input#redeem_winning_state')
    end
  end

  it "renders a submit button" do
    rendered.should have_button('submit')
  end

  it "should have a home link" do
    rendered.should have_link("cancel", href: redeem_winnings_path)
  end

end
