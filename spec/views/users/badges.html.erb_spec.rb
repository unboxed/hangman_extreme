require 'spec_helper'

describe "users/badges" do 

	it "must have a link to description Mr. Loader" do
		render 
		rendered.should have_link('Mr. Loader')
  end 

  it "must have a link to description Clueless" do 
  	render
  	rendered.should have_link('Clueless')
  end 

  it "must have a link to description Brainey" do
  	render
  	rendered.should have_link('Brainey')
  end 

  it "must have a link to description Bookworm" do
  	render 
  	rendered.should have_link('Bookworm')
  end 

  it "must have a link to description Snailing It" do
  	render
  	rendered.should have_link('Snailing It')
  end 

  it "must have a link to description Gladiator" do
  	render
  	rendered.should have_link('Gladiator')
  end 

  it "must have a link to description Warrior" do
  	render
  	rendered.should have_link('Warrior')
  end 

end 