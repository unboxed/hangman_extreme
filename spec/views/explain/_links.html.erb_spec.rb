require 'view_spec_helper'

describe 'explain/_links.html.erb' do

  before(:each) do
    view.stub(:mxit_request?).and_return(true)
    view.stub(:current_user).and_return(stub_model(User, id: 44))
    view.stub(:menu_item)
    view.stub(:guest?)
  end

  it 'must have a link to scoring_categories on menu' do
    view.should_receive(:menu_item).with(anything,explain_path(action: 'scoring_categories'),id: 'scoring_categories')
    render :partial => 'explain/links'
  end

  it 'should have a feedback link on menu' do
    args = {response_type: 'code',
            host: 'test.host',
            protocol: 'http',
            client_id: ENV['MXIT_CLIENT_ID'],
            redirect_uri: mxit_oauth_users_url(host: 'test.host'),
            scope: 'profile/public profile/private',
            state: 'feedback'}
    view.should_receive(:menu_item).with(anything,mxit_authorise_url(args),id: 'feedback')
    render :partial => 'explain/links'
  end

  it 'should have a view rank link if not guest' do
    view.stub(:guest?).and_return(false)
    view.should_receive(:menu_item).with(anything,user_path(44),id: 'view_rank')
    render :partial => 'explain/links'
  end

  it 'wont have a view rank link if guest' do
    view.stub(:guest?).and_return(true)
    view.should_not_receive(:menu_item).with(anything,user_path(44),id: 'view_rank')
    render :partial => 'explain/links'
  end

end
