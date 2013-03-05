require 'spec_helper'

describe "feedback/index.html.erb" do

  before(:each) do
    view.stub!(:menu_item)
  end

  it "should have a support link" do
    render
    rendered.should have_link("support", href: new_feedback_path(:type => 'support'))
  end

  it "should have a suggestion link" do
    render
    rendered.should have_link("suggestion", href: new_feedback_path(:type => 'suggestion'))
  end

  it "should have a home link on menu" do
    view.should_receive(:menu_item).with(anything,'/',id: 'root_page')
    render
  end

end
