require 'features_helper'
require 'support/vcr_helper'

def browse_section(seek)
  visit_home
  click_link('scoring_categories')
  page.should have_content('categories')
  click_link(seek)
  page.should have_content(seek.capitalize)
end

shared_examples 'a knowledge seeker' do
  ['rating', 'streak', 'random', 'payouts'].each do |seek|
    it "must allow to browse explain #{seek} section" do
      browse_section(seek)
    end
  end
end

describe 'explain', :redis => true do
  context 'as mxit user', :google_analytics_vcr => true  do
    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
    end

    it_behaves_like 'a knowledge seeker'
  end

  context 'as guest user', :smaato_vcr => true do
    it_behaves_like 'a knowledge seeker'
  end
end
