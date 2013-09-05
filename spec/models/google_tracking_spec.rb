require 'spec_helper'

describe GoogleTracking, :redis => true do

  context "Validations" do

    it "wont accept no user_id" do
      tracking = GoogleTracking.new
      tracking.should_not be_valid
      tracking.errors[:user_id].should_not be_empty
    end

    it "must have a user_id" do
      tracking = GoogleTracking.new(user_id: 1)
      tracking.should be_valid
      tracking.errors[:user_id].should be_empty
    end

  end

  describe "update_tracking" do

    before :each do
      @tracking = GoogleTracking.new(user_id: rand(99))
    end

    it "must work" do
      Timecop.freeze(Time.current) do
        @tracking.update_tracking.should be_true
        @tracking.update_tracking.should be_false
      end
    end

  end

  describe "utma" do

    before :each do
      @tracking = GoogleTracking.new(user_id: rand(99))
    end

    it "must work" do
      @tracking.utma
    end

  end

  describe "find_or_create_by_user_id" do

    it "must work" do
      tracking = GoogleTracking.find_or_create_by_user_id(1)
      tracking.user_id.should == "1"
    end

  end


end
