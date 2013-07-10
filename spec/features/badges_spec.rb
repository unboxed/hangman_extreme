# encoding: utf-8
require 'spec_helper'

shared_examples "badger" do

  it "must allow to visit the badges page and see descriptions" do
    visit '/'
    click_link 'badges'
    page.should have_content("Badges")
    click_link 'Mr. Loader'
    page.should have_content("credits")
    click_link 'badges'
    page.should have_content("Badges")
    click_link 'Clueless'
    page.should have_content("clues")
    click_link 'badges'
    page.should have_content("Badges")
    click_link 'Brainey'
    page.should have_content("in a row")
    click_link 'badges'
    page.should have_content("Badges")
    click_link 'Bookworm'
    page.should have_content("letter")
    click_link 'badges'
    page.should have_content("Badges")
    click_link 'Snailing It'
    page.should have_content("time")
    click_link 'badges'
    page.should have_content("Badges")
    click_link 'Gladiator'
    page.should have_content("weekly")
    click_link 'badges'
    page.should have_content("Badges")
    click_link 'Warrior'
    page.should have_content("daily")
    click_link 'badges'
    page.should have_content("Badges")
  end

end

describe 'users', :redis => true do

  context "as mxit user", :shinka_vcr => true, :smaato_vcr => true do

    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
    end

    it_behaves_like "badger"

  end

  context "as mobile user", :facebook => true, :smaato_vcr => true, :js => true do

    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it_behaves_like "badger"

  end

  # can't play games
  context "as guest user", :smaato_vcr => true, :js => true do

  end

end