require 'spec_helper'

describe "explain/clueless.html.erb" do 

	before(:each) do
		@user = create(:user)
		view.stub!(:menu_item)
		view.stub!(:current_user).and_return(@user)
	end

	it "must have a link to badges" do
		view.should_receive(:menu_item).with(anything,badges_users_path(action: 'badges'),id: 'badges')
		render
	end 

	it "must describe how to obtain badge clueless" do
		render
		rendered.should have_content('5 clues')
	end 

	it "must show badge if 5 clues were used in a row" do
		create(:badge, user: @user, name: 'Clueless')
		render 
		rendered.should have_content('Achieved this Badge')
	end 

	it "must not create Clueless Badge if <5 clues used and not in a row" do
		render
		rendered.should have_content('Still to Achieve')
	end 
end 
