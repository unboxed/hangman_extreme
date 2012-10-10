require 'spec_helper'

describe "feedback/index.html.erb" do

  it "should have a support link" do
    render
    rendered.should have_link("support", href: new_feedback_path(:type => 'support'))
  end

  it "should have a suggestion link" do
    render
    rendered.should have_link("suggestion", href: new_feedback_path(:type => 'suggestion'))
  end

  it "should have a home link" do
    render
    rendered.should have_link("home", href: root_path)
  end

end
