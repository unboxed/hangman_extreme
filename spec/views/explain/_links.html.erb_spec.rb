require 'spec_helper'

describe "explain/_links.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    view.stub!(:current_user).and_return(stub_model(User, id: 44))
    view.stub!(:menu_item)
  end

  it "should have a home page link on menu" do
    view.should_receive(:menu_item).with(anything,'/',id: 'root_page')
    render :partial => "explain/links"
  end

  it "should have a view rank link on menu" do
    view.should_receive(:menu_item).with(anything,user_path(44),id: 'view_rank')
    render :partial => "explain/links"
  end

  it "must have a link to scoring_categories on menu" do
    view.should_receive(:menu_item).with(anything,explain_path(action: 'scoring_categories'),id: 'scoring_categories')
    render :partial => "explain/links"
  end

  it "should have a feedback link on menu" do
    args = {response_type: 'code',
            host: "test.host",
            protocol: 'http',
            client_id: ENV['MXIT_CLIENT_ID'],
            redirect_uri: mxit_oauth_users_url(host: "test.host"),
            scope: "profile/public profile/private",
            state: "feedback"}
    view.should_receive(:menu_item).with(anything,mxit_authorise_url(args),id: 'feedback')
    render :partial => "explain/links"
  end

end
