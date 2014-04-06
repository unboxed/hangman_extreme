require 'view_spec_helper'

describe 'explain/winning_streak.html.erb' do
  before(:each) do
    stub_template '_links.html.erb' => '<div>Links</div>'
  end

  it 'renders the links' do
    render
    rendered.should have_content('Links')
  end

end
