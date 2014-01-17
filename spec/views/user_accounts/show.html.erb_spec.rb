require 'view_spec_helper'

describe "user_accounts/show.html.erb" do
  before(:each) do
    @user_account = stub_model(UserAccount, real_name: "Grant Petersen", mobile_number: "123", credits: 20)
    view.stub(:current_user).and_return(stub_model(User))
    view.stub(:current_user_account).and_return(@user_account)
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
    rendered.should have_link("edit_real_name", href: edit_user_accounts_path(:field => 'real_name'))
  end

  it "should have a modify mobile number link" do
    render
    rendered.should have_link("edit_mobile_number", href: edit_user_accounts_path(:field => 'mobile_number'))
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
