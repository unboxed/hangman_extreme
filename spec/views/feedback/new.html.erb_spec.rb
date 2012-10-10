require 'spec_helper'

describe "feedback/new.html.erb" do
  include ViewCapybaraRendered

  it "renders a submit button" do
    render
    within('form') do
      rendered.should have_button('submit')
    end
  end

  it "renders feedback field" do
    render
    within('form') do
      rendered.should have_field('feedback')
    end
  end

  it "should have a home link" do
    render
    rendered.should have_link("cancel", href: root_path)
  end

end
