require 'spec_helper'

shared_examples "a game player" do

  it "must allow you to start a new game and lose" do
    Dictionary.clear
    Dictionary.add("tester")
    visit_home
    click_link('Play')
    click_button 'start_game'
    i = 10
    page.should have_content("#{i} attempts left")
    %W(a b c d f g h i k).each do |letter|
      save_and_open_page if letter == 'c'
      active_page_click_link(letter)
      i-= 1
      page.should have_content("#{i} attempts left")
      page.should have_content("_ _ _ _ _ _")
    end
    active_page_click_link 'j'
    page.should have_content("You lose")
    page.should have_content("t e s t e r")
    page.should have_link('new game')
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
    active_page_click_link 'show_clue'
    click_button 'yes'
    page.should have_content("kevin")
    active_page_click_link 'j'
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
    active_page_click_link('a')
    page.should have_content("9 attempts left")
    page.should have_content("_ _ _ _ _ _")
    active_page_click_link('b')
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
    active_page_click_link('a')
    page.should have_content("_ _ _ _ _ _")
    active_page_click_link('b')
    page.should have_content("b _ _ _ _ _")
    active_page_click_link('e')
    page.should have_content("b e _ _ e _") # better
    active_page_click_link('t')
    page.should have_content("b e t t e _")
    active_page_click_link('r')
    page.should have_content("You win")
    page.should have_content("b e t t e r")
    click_link 'new_game'
    click_button 'start_game'
    page.should have_content("_ _ _ _ _ _")
  end

end

describe 'games', :redis => true do

  context "as mxit user", :shinka_vcr => true do

    before :each do
      @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
      add_headers('X_MXIT_USERID_R' => 'm2604100')
      set_mxit_headers # set mxit user
    end

    it_behaves_like "a game player"

    it "must show ads" do
      visit_home
      page.should have_css("div.beacon")
    end

  end

  context "as mobile user", :facebook => true, :smaato_vcr => true, :js => true do

    before :each do
      @current_user = create(:user, uid: '1234567', provider: 'facebook')
      visit '/auth/facebook'
    end

    it_behaves_like "a game player"

    it "must show ads" do
      visit_home
      page.should have_css("div.footer img")
    end

  end

  context "as guest user", :smaato_vcr => true, :js => true do

    it "wont allow you to start a new game" do
      visit_home
      click_link('Play')
      page.current_path.should == "/"
    end

    it "must show ads" do
      visit_home
      page.should have_css("div.footer img")
    end

  end

end