require 'spec_helper'

def browse_section(seek)
  visit_home
  click_link('scoring_categories')
  page.should have_content("categories")
  click_link(seek)
  page.should have_content(seek.capitalize)
end

shared_examples "a knowledge seeker" do

  ['rating', 'streak', 'random', 'payouts'].each do |seek|

    it "must allow to browse explain #{seek} section" do
      browse_section(seek)
    end

  end

end

describe 'explain', :redis => true do

  context "as mxit user", :google_analytics_vcr => true  do

    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
    end

    it_behaves_like "a knowledge seeker"

  end

  context "as mobile user", :facebook => true, :smaato_vcr => true, :js => true do

    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it_behaves_like "a knowledge seeker"

  end

  context "as guest user", :smaato_vcr => true do

    it_behaves_like "a knowledge seeker"

  end

  # used to test cache
  context "multiple users", :google_analytics_vcr => true, :smaato_vcr => true  do

    it "must allow to browse explain all sections" do
      setup_sessions
      ['rating', 'streak', 'random', 'payouts'].each do |seek|
        using_facebook_session do
          browse_section(seek)
          click_link('Home')
        end
        using_mxit_session do
          browse_section(seek)
          click_link('Home')
        end
        using_guest_session do
          browse_section(seek)
        end
      end
    end

  end

end