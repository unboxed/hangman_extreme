require 'view_spec_helper'

describe "users/edit" do

  before(:each) do
    assign(:user, stub_model(User))
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
      rendered.should have_field('user_real_name')
      rendered.should_not have_field('user_mobile_number')
    end
  end

  it "renders mobile number only" do
    view.stub(:params).and_return(field: 'mobile_number')
    render
    within('form') do
      rendered.should_not have_field('user_real_name')
      rendered.should have_field('user_mobile_number')
    end
  end


end
