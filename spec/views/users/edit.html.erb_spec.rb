require 'spec_helper'

describe "users/edit" do
  include ViewCapybaraRendered

  before(:each) do
    assign(:user, stub_model(User))
  end

  it "renders new game form" do
    render
    within('form') do
      rendered.should have_field('user_real_name')
      rendered.should have_field('user_mobile_number')
      rendered.should have_button('submit')
    end
  end


end
