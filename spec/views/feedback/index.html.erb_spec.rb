require 'view_spec_helper'

describe 'feedback/index.html.erb' do

  before(:each) do
    view.stub(:mxit_request?).and_return(true)
    view.stub(:menu_item)
  end

  it 'should have a support link' do
    render
    rendered.should have_link('1', href: new_feedback_path(:type => 'support'))
  end

  it 'should have a suggestion link' do
    render
    rendered.should have_link('2', href: new_feedback_path(:type => 'suggestion'))
  end

end
