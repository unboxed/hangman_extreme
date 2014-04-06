require 'spec_helper'

describe AdHelper do

  context 'shinka_ads_enabled?', :redis => true do

    it 'wont work if shinka_auid is blank' do
      helper.stub(:shinka_auid).and_return(nil)
      helper.should_not be_shinka_ads_enabled
    end

    it 'must work if shinka_auid' do
      helper.stub(:shinka_auid).and_return('123')
      helper.should be_shinka_ads_enabled
    end

  end

  context 'shinka_ad' do

    before :each do
      helper.stub(:shinka_ads_enabled?).and_return(true)
      helper.stub(:shinka_auid).and_return('123')
    end

    it 'must return mxit advert tag' do
      helper.shinka_ad.should == "<mxit:advert auid=\"123\"/>"
    end

    it 'must return blank if shinka ads disabled' do
      helper.stub(:shinka_ads_enabled?).and_return(false)
      helper.shinka_ad.should be_blank
    end

  end

end
