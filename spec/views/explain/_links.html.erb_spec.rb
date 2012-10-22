require 'spec_helper'

describe "explain/_links.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    view.stub!(:current_user).and_return(stub_model(User, id: 44))
  end

  it "should have a home page link" do
    render :partial => "explain/links"
    rendered.should have_link("root_page", href: '/')
  end

  it "should have a view rank link" do
    render :partial => "explain/links"
    rendered.should have_link("view_rank", href: user_path(44))
  end

  it "must have a link to scoring_categories" do
    render :partial => "explain/links"
    rendered.should have_link("scoring_categories", href: explain_path(action: 'scoring_categories'))
  end

  it "should have a feedback link" do
    render :partial => "explain/links"
    rendered.should have_link("feedback", href: mxit_authorise_url(response_type: 'code',
                                                                   host: "test.host",
                                                                   client_id: ENV['MXIT_CLIENT_ID'],
                                                                   redirect_uri: mxit_oauth_users_url(host: "test.host"),
                                                                   scope: "profile/public profile/private",
                                                                   state: "feedback"))
  end


end
