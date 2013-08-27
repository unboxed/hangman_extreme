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

  def click_letter(l)
    within(".letters") do 
      click_link(l)
    end 
  end 

  it "Bookworm is received after win of 10 letter word with no clues used" do 
  
  # Should not give badge if clues were used
    Dictionary.clear
    Dictionary.add("television")
    Dictionary.set_clue("television","tv")
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _ _ _ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %W(t e l v i s o n).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Bookworm")

  # 10 letter win completed with no clues
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _ _ _ _ _ _")
    %W(t e l v i s o n).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_content("Bookworm")
    click_link 'Bookworm'
    page.should have_content("Achieved")

  #should not give the badge twice
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _ _ _ _ _ _")
    %W(t e l v i s o n).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win") 
    page.should have_no_content("Bookworm")
  end 

  it "should not give badge if word is less than 10" do 
    Dictionary.clear
    Dictionary.add("airport")
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _ _ _")
    %W(a i r p o t).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win") 
    page.should have_no_content("Bookworm")
  end

end

describe 'users', :redis => true do

  context "as mxit user", :google_analytics_vcr => true do

    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
    end

    it_behaves_like "badger"

    it "Mr_Loader badge is received after credits purchased" do
      ENV['MXIT_VENDOR_ID'] ||= '1'
      visit_home
      click_link('buy_credits')
      click_link('buy_credits11')
      click_link('submit')
      page.should have_content("Mr. Loader")
      click_link 'Mr. Loader'
      page.should have_content("bought credits")
      page.should have_content("Achieved")

      # Should not give the badge twice 
      visit_home
      click_link('buy_credits')
      click_link('buy_credits11')
      click_link('submit')
      page.should have_no_content("Mr. Loader")
    end

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