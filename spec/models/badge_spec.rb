require 'spec_helper'

describe Badge do
  
  it "must have a name" do
    Badge.new.should have_at_least(1).errors_on(:name)
    Badge.new(name: "Mr. Loader").should have(0).errors_on(:name)
  end

   it "must have a valid name" do
    Badge.new(name: "Mr. Loader").should have(0).errors_on(:name)
    Badge.new(name: "Bookworm").should have(0).errors_on(:name)
    Badge.new(name:'Clueless').should have(0).errors_on(:name)
    Badge.new(name: "xx").should have(1).errors_on(:name)
  end

  it "must have a user" do
  	Badge.new.should have(1).errors_on(:user_id)
		Badge.new(user_id: 1).should have(0).errors_on(:user_id)
	end 

	it "must have one Mr. Loader badge per user" do 
		Badge.create!(name: "Mr. Loader", user_id:1)
		Badge.new(name: "Mr. Loader", user_id:1).should have(1).errors_on(:name)
	end 

  it "must have one Bookworm badge per user" do 
    Badge.create!(name: "Bookworm", user_id:1)
    Badge.new(name: "Bookworm", user_id:1).should have(1).errors_on(:name)
  end

  it "must have one Clueless badge per user" do
    Badge.create!(name: "Clueless", user_id:1)
    Badge.new(name: "Clueless", user_id:1).should have(1).errors_on(:name)
  end 

end
