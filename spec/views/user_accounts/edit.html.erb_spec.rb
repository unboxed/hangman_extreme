require 'view_spec_helper'

describe "user_accounts/edit" do
  before(:each) do
    assign(:user_account, stub_model(UserAccount))
  end

  it "renders a submit button" do
    render
    within('form') do
      rendered.should have_button('submit')
    end
  end

  it "renders real name only" do
    view.stub(:params).and_return(field: 'real_name')
    render
    within('form') do
      rendered.should have_field('user_account_real_name')
      rendered.should_not have_field('user_account_mobile_number')
    end
  end

  it "renders mobile number only" do
    view.stub(:params).and_return(field: 'mobile_number')
    render
    within('form') do
      rendered.should_not have_field('user_account_real_name')
      rendered.should have_field('user_account_mobile_number')
    end
  end
end
