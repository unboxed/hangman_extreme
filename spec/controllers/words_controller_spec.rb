require 'spec_helper'

describe WordsController do

  before :each do
    @current_user = create(:user)
    controller.stub(:current_user).and_return(@current_user)
  end

  describe "GET 'define'" do

    before :each do
      Dictionary.stub(:define).and_return(["Noun","The Definition"])
    end

    it "returns http success" do
      get 'define', word: 'dog'
      response.should be_success
    end

    it "must get the definition" do
      Dictionary.should_receive(:define).with("dog").and_return("The Definition")
      get 'define', word: 'dog'
      assigns(:definition).should == "The Definition"
    end

  end

end
