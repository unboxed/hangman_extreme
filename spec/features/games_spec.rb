require 'features_helper'

shared_examples "a game player" do

  def click_letter(l)
    within(".letters") do
      click_link(l)
    end
  end

  it "must allow you to start a new game and lose" do
    Dictionary.clear
    Dictionary.add("tester")
    visit_home
    click_link('Play')
    click_button 'start_game'
    i = 10
    page.should have_content("#{i} attempts left")
    %W(a b c d f g h i k).each do |letter|
      click_letter(letter)
      i-= 1
      page.should have_content("#{i} attempts left")
      page.should have_content("_ _ _ _ _ _")
    end
    click_link 'j'
    page.should have_content("You lose")
    page.should have_content("t e s t e r")
    page.should have_link('new_game')
    page.should have_link('Home')
  end

  it "must allow you to use your credits to reveal the clue" do
    Dictionary.clear
    Dictionary.add("tester")
    Dictionary.set_clue("tester", "kevin")
    visit_home
    click_link('Play')
    click_button 'start_game'
    page.should have_no_content("kevin")
    click_link 'show_clue'
    click_button 'yes'
    page.should have_content("kevin")
    click_letter 'j'
    page.should have_content("9 attempts left")
    page.should have_content("kevin")
  end

  it "must allow you to start a new game and leave and continue it later" do
    Dictionary.clear
    Dictionary.add("better")
    visit_home
    click_link('Play')
    click_button 'start_game'
    page.should have_content("_ _ _ _ _ _")
    click_letter('a')
    page.should have_content("9 attempts left")
    page.should have_content("_ _ _ _ _ _")
    click_letter('b')
    page.should have_content("b _ _ _ _ _")
    click_link('Home')
    click_link("Play")
    page.should have_content("b _ _ _ _ _")
  end

  it "must allow you to play multiple games" do
    Dictionary.clear
    Dictionary.add("better")
    visit_home
    click_link('Play')
    click_button 'start_game'
    page.should have_content("_ _ _ _ _ _")
    click_letter('a')
    page.should have_content("_ _ _ _ _ _")
    click_letter('b')
    page.should have_content("b _ _ _ _ _")
    click_letter('e')
    page.should have_content("b e _ _ e _") # better
    click_letter('t')
    page.should have_content("b e t t e _")
    click_letter('r')
    page.should have_content("You win")
    page.should have_content("b e t t e r")
    click_link 'new_game'
    click_button 'start_game'
    page.should have_content("_ _ _ _ _ _")
  end

end

describe 'games', :redis => true do

  context "as mxit user", :google_analytics_vcr => true, :user_accounts_vcr => true do

    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
    end

    it_behaves_like "a game player"

  end

  context "as mobile user", :facebook => true, :smaato_vcr => true, :js => true, :user_accounts_vcr => true do

    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it_behaves_like "a game player"

  end

  context "as guest user", :smaato_vcr => true, :js => true do

    it "wont allow you to start a new game" do
      visit_home
      click_link('Play')
      page.current_path.should == "/"
    end

  end

end
