require 'spec_helper'

describe "explain/wins.html.erb" do

  before(:each) do
    stub_template "_links.html.erb" => "<div>Links</div>"
  end

  it "renders the links" do
    render
    rendered.should have_content("Links")
  end

  it "must have a link to points" do
    render
    rendered.should have_link("points", href: explain_path(action: 'points'))
  end

end
