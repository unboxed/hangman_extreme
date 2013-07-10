require 'spec_helper'

describe "explain/gladiator.html.erb" do 

	before(:each) do
		view.stub!(:menu_item)
	end

	it "must have a link to badges" do
		view.should_receive(:menu_item).with(anything,badges_users_path(action: 'badges'),id: 'badges')
		render
	end 

	it "must describe how to obtain badge Gladiator" do
		render
		rendered.should have_content('weekly') 
	end 

end 