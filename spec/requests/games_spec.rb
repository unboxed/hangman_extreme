require 'spec_helper'

shared_examples "a game player" do

  it "must allow you to start a new game and win" do
    Dictionary.clear
    Dictionary.add("better")
    visit '/'
    click_link('play_game')
    click_button 'start_game'
    page.should have_content("_ _ _ _ _ _")
    click_link('a')
    page.should have_content("_ _ _ _ _ _")
    click_link('b')
    page.should have_content("b _ _ _ _ _")
    click_link('e')
    page.should have_content("b e _ _ e _") # better
    click_link('t')
    page.should have_content("b e t t e _")
    click_link('r')
    page.should have_content("You win")
    page.should have_content("b e t t e r")
    page.should have_link('new_game')
    page.should have_link('home')
  end

  it "must allow you to start a new game and lose" do
    Dictionary.clear
    Dictionary.add("tester")
    visit '/'
    click_link('play_game')
    click_button 'start_game'
    i = 10
    page.should have_content("#{i} attempts left")
    %W(a b c d f g h i k).each do |letter|
      click_link(letter)
      i-= 1
      page.should have_content("#{i} attempts left")
      page.should have_content("_ _ _ _ _ _")
    end
    click_link 'j'
    page.should have_content("You lose")
    page.should have_content("t e s t e r")
    page.should have_link('new_game')
    page.should have_link('home')
  end

  it "must allow you to use your clue points if reveal the clue" do
    Dictionary.clear
    Dictionary.add("tester")
    Dictionary.set_clue("tester", "kevin")
    visit '/'
    click_link('play_game')
    click_button 'start_game'
    page.should have_no_content("kevin")
    click_link 'show_clue'
    page.should have_content("kevin")
    click_link 'j'
    page.should have_content("kevin")
  end

  it "must allow you to start a new game and leave and continue it later" do
    Dictionary.clear
    Dictionary.add("better")
    visit '/'
    click_link('play_game')
    click_button 'start_game'
    page.should have_content("_ _ _ _ _ _")
    click_link('a')
    page.should have_content("_ _ _ _ _ _")
    click_link('b')
    page.should have_content("b _ _ _ _ _")
    click_link('home')
    click_link("play_game")
    page.should have_content("b _ _ _ _ _")
  end

  it "must allow you to play multiple games" do
    Dictionary.clear
    Dictionary.add("better")
    visit '/'
    click_link('play_game')
    click_button 'start_game'
    page.should have_content("_ _ _ _ _ _")
    click_link('a')
    page.should have_content("_ _ _ _ _ _")
    click_link('b')
    page.should have_content("b _ _ _ _ _")
    click_link('e')
    page.should have_content("b e _ _ e _") # better
    click_link('t')
    page.should have_content("b e t t e _")
    click_link('r')
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
      visit '/'
      page.should have_css("div.beacon")
    end

  end

  context "as mobile user", :smaato_vcr => true do

    before :each do
      @current_user = create(:user, uid: '1234567', provider: 'facebook')
    end

    it_behaves_like "a game player"

    it "must show ads" do
      visit '/'
      page.should have_css("div.footer img")
    end

  end

end