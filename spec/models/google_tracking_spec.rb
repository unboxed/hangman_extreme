require 'spec_helper'

describe GoogleTracking, :vcr => :once do

  context "Validations" do

    it "must have a user_id" do
      GoogleTracking.new.should have(1).errors_on(:user_id)
      GoogleTracking.new(user_id: 1).should have(0).errors_on(:user_id)
    end

  end

  describe "update_tracking" do

    before :each do
      @tracking = GoogleTracking.new(user_id: rand(99))
    end

    it "must work" do
      @tracking.update_tracking
    end

  end

  describe "find_or_create_by_user_id" do

    it "must work" do
      tracking = GoogleTracking.find_or_create_by_user_id(1)
      tracking.user_id.should == "1"
    end

  end


end