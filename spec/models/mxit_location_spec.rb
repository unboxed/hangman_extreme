require 'spec_helper'

describe MxitProfile do

  context 'assigning header information' do

    before :all do
      @mxit_location = MxitLocation.new('ZA,South Africa,11,Western Cape,23,Kraaifontein,88,13072382,8fbe253')
    end

    it 'must assign the right country' do
      @mxit_location.country.should be == 'ZA'
    end

    it 'must assign the principal subdivision' do
      @mxit_location.principal_subdivision.should be == '11'
    end

    it 'must assign the city' do
      @mxit_location.city.should be == '23'
    end

    it 'must assign the right network operator id' do
      @mxit_location.network_operator_id.should be == '88'
    end

    it 'must assign the right client features bitset' do
      @mxit_location.client_features_bitset.should be == '13072382'
    end

    it 'must assign the right cell id' do
      @mxit_location.cell_id.should be == '8fbe253'
    end

  end


end
