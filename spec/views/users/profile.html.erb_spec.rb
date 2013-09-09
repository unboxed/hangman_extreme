require 'spec_helper'

describe "users/profile.html.erb" do

  before(:each) do
    @user = stub_model(User, real_name: "Grant Petersen", mobile_number: "123", credits: 20)
    view.stub(:current_user).and_return(@user)
    view.stub(:mxit_request?).and_return(true)
    view.stub(:menu_item)
  end

  it "must show real name and mobile number" do
    render
    rendered.should have_content("Grant Petersen")
    rendered.should have_content("123")
    rendered.should have_content("20 credits")
  end

  it "should have a modify real name link" do
    render
    rendered.should have_link("edit_real_name", href: edit_user_path(@user, :field => 'real_name'))
  end

  it "should have a modify mobile number link" do
    render
    rendered.should have_link("edit_mobile_number", href: edit_user_path(@user, :field => 'mobile_number'))
  end

  it "should have a buy more clue points link" do
    view.should_receive(:menu_item).with(anything,purchases_path,id: 'buy_credits')
    render
  end

  it "should have a buy more clue points link" do
    view.should_receive(:menu_item).with(anything,purchases_path,id: 'buy_credits')
    render
  end

end
