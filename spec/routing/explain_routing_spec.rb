require 'spec_helper'

describe ExplainController do
  describe 'routing' do

    it 'routes to #index' do
      get('/about').should route_to('explain#about')
    end

  end
end
