require 'spec_helper'

describe MxitProfile do

  context 'assigning header information' do

    before :all do
      @mxit_profile = MxitProfile.new('en,ZA,1983-01-18,Male,2')
    end

    it 'must assign the right gender' do
      @mxit_profile.gender.should == 'male'
    end

    it 'must assign the right country' do
      @mxit_profile.country.should == 'ZA'
    end

    it 'must assign the right date of birth' do
      @mxit_profile.dob.should == '1983-01-18'
    end

    it 'must return the correct age' do
      @mxit_profile.should_receive(:dob).at_least(:once).and_return(29.years.ago.to_date.to_s(:db))
      @mxit_profile.age.should == 29
    end

    it 'must assign the right tariff plan' do
      @mxit_profile.tariff_plan.should == '2'
    end

    it 'must assign the right language' do
      @mxit_profile.language.should == 'en'
    end

  end


end
