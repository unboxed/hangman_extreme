require 'spec_helper'

describe ExplainController do

  describe "GET 'scoring_categories'" do
    it "returns http success" do
      get 'scoring_categories'
      response.should be_success
    end
  end

  describe "GET 'wins'" do
    it "returns http success" do
      get 'wins'
      response.should be_success
    end
  end

  describe "GET 'precision'" do
    it "returns http success" do
      get 'precision'
      response.should be_success
    end
  end

  describe "GET 'rating'" do
    it "returns http success" do
      get 'rating'
      response.should be_success
    end
  end

  describe "GET 'points'" do
    it "returns http success" do
      get 'points'
      response.should be_success
    end
  end

  describe "GET 'winning_streak'" do
    it "returns http success" do
      get 'winning_streak'
      response.should be_success
    end
  end

end
