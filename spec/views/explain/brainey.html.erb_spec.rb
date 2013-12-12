require 'spec_helper'

describe "explain/brainey.html.erb" do 

	before(:each) do
		@user = create(:user)
		view.stub!(:menu_item)
		view.stub!(:current_user).and_return(@user)
	end

	it "must have a link to badges" do
		view.should_receive(:menu_item).with(anything,badges_users_path(action: 'badges'),id: 'badges')
		render
	end 

	it "must describe how to obtain badge brainey" do
		render
		rendered.should have_content('row')
	end 

	it "must show badge if 10 games were won and no clues used" do 
		create(:badge, user: @user, name: 'Brainey')
		render
		rendered.should have_content('Achieved this Badge')
	end

	it "must not show badge if <10 games were won in a row" do 
		render
		rendered.should have_content('Still to Achieve')
	end 

end 
