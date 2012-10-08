require 'spec_helper'

describe "users/profile.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @user = stub_model(User, real_name: "Grant Petersen", mobile_number: "123")
    view.stub(:current_user).and_return(@user)
  end

  it "must show real name and mobile number" do
    render
    rendered.should have_content("Grant Petersen")
    rendered.should have_content("123")
  end

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a modify real name link" do
    render
    rendered.should have_link("edit_real_name", href: edit_user_path(@user, :field => 'real_name'))
  end

  it "should have a modify mobile number link" do
    render
    rendered.should have_link("edit_mobile_number", href: edit_user_path(@user, :field => 'mobile_number'))
  end

end
