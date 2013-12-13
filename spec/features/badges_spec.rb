# encoding: utf-8
require 'features_helper'

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

  it "Clueless Badge received after using 5 clues in a row" do 
    Dictionary.clear
    Dictionary.add("duck")
    Dictionary.set_clue("duck", "quack")
#first play with clue
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Clueless")
#second play with clue
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Clueless")    
#third play with clue
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Clueless")    
#forth play with clue
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Clueless")    
#fifth play with clue 
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_content("Clueless")
    click_link 'Clueless'
    page.should have_content("Achieved")
  
  #should not give the badge twice
#first play with clue
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Clueless")
#second play with clue
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Clueless")    
#third play with clue
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Clueless")    
#forth play with clue
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Clueless")    
#fifth play with clue 
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(d u c k).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should_not have_content("Clueless")
  end

  it "Brainey is received after winning 10 words in a row without using clues" do
    Dictionary.clear
    Dictionary.add("meaow")
    Dictionary.set_clue("meaow","cat")
#should not give badge if clues were used
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #2nd play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #3rd play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #4th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #5th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #6th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #7th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #8th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #9th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #10th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    click_link 'show_clue'
    click_button 'yes'
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

#should give badge if no clues were used
    #1st play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #2nd play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #3rd play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #4th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #5th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #6th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #7th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #8th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #9th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #10th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_content("Brainey")
    click_link 'Brainey'
    page.should have_content("Achieved")
  # does not give the badge twice 
   #1st play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #2nd play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #3rd play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #4th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #5th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #6th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #7th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #8th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #9th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")

    #10th play with win
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _")
    %w(m e a o w).each do |letter|
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Brainey")
    end 

  it "Should not give the Quickster Badge if game played longer than 30s" do 
    Dictionary.clear
    Dictionary.add("cattle")
    Dictionary.set_clue("cattle","ranch")
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _ _")
    sleep(35)
    %w(c a t l e).each do |letter|
      page.should have_content("10 attempts")
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Quickster")
  end 

  it "should not give the Quickster Badge if game played under 30s and a clue was used" do 
    Dictionary.clear
    Dictionary.add("cattle")
    Dictionary.set_clue("cattle","ranch")
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _ _")
    sleep(5)
    click_link 'show_clue'
    click_button 'yes'
    %w(c a t l e).each do |letter|
      page.should have_content("10 attempts")
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Quickster")
  end 

  it "should give the Quickster Badge if game played under 30s and a clue was not used" do 
    Dictionary.clear
    Dictionary.add("cattle")
    Dictionary.set_clue("cattle","ranch")
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _ _")
    sleep(5)
    %w(c a t l e).each do |letter|
      page.should have_content("10 attempts")
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_content("Quickster")
#should not give badge twice
    visit_home
    click_link('Play')
    click_button('start_game')
    page.should have_content("_ _ _ _ _ _")
    sleep(5)
    %w(c a t l e).each do |letter|
      page.should have_content("10 attempts")
      click_letter(letter)
    end 
    page.should have_content("You win")
    page.should have_no_content("Quickster")  
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
