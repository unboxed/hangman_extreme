require 'view_spec_helper'

describe 'layouts/application' do
  before(:each) do
    @current_user = stub_model(User, id: 50)
    view.stub(:current_user).and_return(@current_user)
    view.stub(:current_page?).and_return(false)
    view.stub(:menu)
    view.stub(:shinka_ad)
  end

  it 'should a menu' do
    view.stub(:menu).and_return('--MENU--')
    render
    rendered.should have_content('--MENU--')
  end

  it 'should a ad' do
    view.stub(:shinka_ad).and_return('--AD--')
    render
    rendered.should have_content('--AD--')
  end
end
