require 'spec_helper'

describe WordsController do

  before :each do
    @current_user = create(:user)
    controller.stub(:current_user).and_return(@current_user)
    controller.stub(:send_stats)
  end

  describe "GET 'define'" do

    before :each do
      Dictionary.stub(:define).and_return(["Noun","The Definition"])
    end

    it "returns http success" do
      get 'define', word: 'dog'
      response.should be_success
    end

  end

end
