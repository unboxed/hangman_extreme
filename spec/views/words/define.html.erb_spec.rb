require 'spec_helper'

describe "words/define.html.erb" do

  before(:each) do
    @definition = assign(:definition, "The Text definition")
    view.stub(:current_user).and_return(stub_model(User, id: 50))
    view.stub(:menu_item)
  end

  it "must show the definition" do
    render
    rendered.should have_content(@definition)
  end

  it "should have a view rank link on menu" do
    view.should_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

end
