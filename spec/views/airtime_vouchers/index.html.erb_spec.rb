require 'spec_helper'

describe "airtime_vouchers/index.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @airtime_vouchers =
    assign(:airtime_vouchers, [
      stub_model(AirtimeVoucher, id: 100, pin: "hello", sellvalue: "5", network: "cellc"),
      stub_model(AirtimeVoucher, id: 101, pin: "aaaaa", sellvalue: "10", network: "vodacam")
    ])
    view.stub!(:menu_item)
  end

  it "renders a list of airtime_vouchers" do
    render
    within("#airtime_voucher_100") do
      rendered.should have_content("R5 cellc airtime: hello")
    end
    within("#airtime_voucher_101") do
      rendered.should have_content("R10 vodacam airtime: aaaaa")
    end
  end

  it "renders no vouchers redeemed" do
    assign(:airtime_vouchers, [])
    render
    rendered.should have_content("You have not redeem prize points for any vouchers")
  end

  it "must have a link to redeem winnings if user have prize points" do
    view.should_receive(:menu_item).with(anything,redeem_winnings_path,id: 'redeem')
    render
  end

end
