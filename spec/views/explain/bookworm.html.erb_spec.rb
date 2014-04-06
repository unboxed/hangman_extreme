require 'spec_helper'

describe 'explain/bookworm.html.erb' do

	before(:each) do
		@user = create(:user)
		view.stub!(:menu_item)
		view.stub!(:current_user).and_return(@user)
	end

	it 'must have a link to badges' do
		view.should_receive(:menu_item).with(anything,badges_users_path(action: 'badges'),id: 'badges')
		render
	end 

	it 'must describe how to obtain badge bookworm' do
		render
		rendered.should have_content('10 letter') 
	end 

	it 'must show badge if >10 letter word won with no clues' do
		create(:badge, user: @user, name: 'Bookworm')
		render
		rendered.should have_content('Achieved this Badge')
	end 

	it 'must not create Bookworm badge if clue used / <10 letter word completed' do
		render
		rendered.should have_content('Still to Achieve')
	end 

end 
