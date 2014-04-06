require 'spec_helper'

describe 'explain/quickster.html.erb' do

	before(:each) do
		@user = create(:user)
		view.stub!(:menu_item)
		view.stub!(:current_user).and_return(@user)
	end

	it 'must have a link to badges' do
		view.should_receive(:menu_item).with(anything,badges_users_path(action: 'badges'),id: 'badges')
		render
	end 

	it 'must describe how to obtain badge Snailing It' do
		render
		rendered.should have_content('seconds') 
	end 

	it 'must show  Quickster badge if game was completed in under 30s with no clue used' do
		create(:badge, user: @user, name: 'Quickster')
		render 
		rendered.should have_content('Achieved this Badge')
	end 

	it 'must not create Quickster Badge if completed in over 30s' do
		render
		rendered.should have_content('Still to Achieve')
	end 
end 
