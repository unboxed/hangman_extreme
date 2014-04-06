require 'spec_helper'

describe ExplainController do

  before :each do
    controller.stub(:send_stats)
  end

  describe "GET 'scoring_categories'" do
    it 'returns http success' do
      get 'scoring_categories'
      response.should be_success
    end
  end

  describe "GET 'rating'" do
    it 'returns http success' do
      get 'rating'
      response.should be_success
    end
  end

  describe "GET 'winning_streak'" do
    it 'returns http success' do
      get 'winning_streak'
      response.should be_success
    end
  end

  describe "GET 'payouts'" do
    it 'returns http success' do
      get 'payouts'
      response.should be_success
    end
  end

end
