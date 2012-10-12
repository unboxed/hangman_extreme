require 'spec_helper'

describe 'Starting a new practice game' do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
    add_headers('X_MXIT_USERID_R' => 'm2604100')
    set_mxit_headers # set mxit user
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
  end

  it "must allow you to start a new practice game and win" do
    Dictionary.clear
    Dictionary.add("better")
    visit '/'
    click_link('new_game')
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
    page.should have_link('games_index')
  end

  it "must allow you to start a new practice game and lose" do
    Dictionary.clear
    Dictionary.add("tester")
    visit '/'
    click_link('new_game')
    click_button 'start_game'
    %W(a b c d f g h i k).each do |letter|
      click_link(letter)
      page.should have_content("_ _ _ _ _ _")
    end
    click_link 'j'
    page.should have_content("You lose")
    page.should have_content("t e s t e r")
    page.should have_link('new_game')
    page.should have_link('games_index')
  end

  it "must allow you to use your clue points if reveal the clue" do
    Dictionary.clear
    Dictionary.add("tester")
    Dictionary.set_clue("tester","kevin")
    visit '/'
    click_link('new_game')
    click_button 'start_game'
    page.should_not have_content("kevin")
    click_link 'show_clue'
    page.should have_content("kevin")
    click_link 'j'
    page.should have_content("kevin")
  end

end