require 'view_spec_helper'

describe 'explain/_links.html.erb' do

  before(:each) do
    view.stub(:current_user).and_return(stub_model(User, id: 44))
    view.stub(:menu_item)
  end

  it 'must have a link to scoring_categories on menu' do
    view.should_receive(:menu_item).with(anything,explain_path(action: 'scoring_categories'),id: 'scoring_categories')
    render :partial => 'explain/links'
  end

  it 'should have a feedback link on menu' do
    view.should_receive(:menu_item).with(anything,'/feedback',id: 'feedback')
    render :partial => 'explain/links'
  end

  it 'should have a view rank link' do
    view.should_receive(:menu_item).with(anything,user_path(44),id: 'view_rank')
    render :partial => 'explain/links'
  end
end
