require 'spec_helper'

describe BadgeTracker do

	it "must have a user" do
		BadgeTracker.new.should have(1).errors_on(:user_id)
		BadgeTracker.new(user_id: 1).should have(0).errors_on(:user_id)
	end 

	it "must have clues_revealed" do
		BadgeTracker.new(clues_revealed: nil).should have(1).errors_on(:clues_revealed)
	end 

	it "must not have negative clues_revealed" do
		BadgeTracker.new(clues_revealed: -1).should have(1).errors_on(:clues_revealed)
	end 

	it "must accept positive clues_revealed" do
		BadgeTracker.new(clues_revealed: 0).should have(0).errors_on(:clues_revealed)
		BadgeTracker.new(clues_revealed: 1).should have(0).errors_on(:clues_revealed)
	end 

end
