require 'spec_helper'

describe UserRequestInfo do

  context 'assigning information' do

    before :all do
      @request = UserRequestInfo.new(user_agent: 'Agent', language: 'en', gender: 'male', age: 30,
                                     country: 'South Africa', area: 'Western Cape')
    end

    it do
      @request.user_agent.should be == 'Agent'
    end

    it do
      @request.language.should be == 'en'
    end

    it do
      @request.gender.should be == 'male'
    end

    it do
      @request.age.should be == '30'
    end

    it  do
      @request.country.should be == 'South Africa'
    end

    it do
      @request.area.should be == 'Western Cape'
    end

    context 'assigning mxit location' do

      before :all do
        @mxit_location = MxitLocation.new('NA,Nambia,11,Cape,23,Kraaifontein,88,13072382,8fbe253')
      end

      it 'must assign the right country' do
        @request.mxit_location = @mxit_location
        @request.country.should be == 'Nambia'
      end

      it 'must assign the area' do
        @request.mxit_location = @mxit_location
        @request.area.should be == 'Kraaifontein'
      end

      it 'must assign the code if country name is blank' do
        @mxit_location.stub(:country_name).and_return('')
        @request.mxit_location = @mxit_location
        @request.country.should be == 'NA'
      end

      it 'must assign the area code if city_name is blank' do
        @mxit_location.stub(:city_name).and_return('')
        @request.mxit_location = @mxit_location
        @request.area.should be == '23'
      end

    end

    context 'assigning mxit profile' do

      before :each do
        @mxit_profile = MxitProfile.new('afr,ZA,1983-01-18,Female,2')
        @mxit_profile.stub(:age).and_return(29)
        @request.mxit_profile = @mxit_profile
      end

      it 'must assign the right gender' do
        @request.gender.should be == 'female'
      end

      it 'must assign the right country' do
        @request.country.should be == 'ZA'
      end

      it 'must return the correct age' do
        # result must be a string, not a integer
        @request.age.should be == '29'
      end

      it 'must assign the right language' do
        @request.language.should be == 'afr'
      end

    end

  end


end
