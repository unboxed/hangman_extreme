require 'spec_helper'

describe FeedbackController do
  describe 'routing' do
    it 'routes to #index' do
      get('/user_comments').should route_to('feedback#index')
    end

    it 'routes to #new' do
      get('/user_comments/new').should route_to('feedback#new')
    end

    it 'routes to #create' do
      post('/user_comments').should route_to('feedback#create')
    end
  end
end
