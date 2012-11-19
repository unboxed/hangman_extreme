require 'spec_helper'

describe "games/show" do
  before(:each) do
    @game = assign(:game, stub_model(Game,attempts_left: 5,
                                          hangman_text: "__t__",
                                          word: "cltdo",
                                          done?: false,
                                          is_won?: false,
                                          is_lost?: false))
    view.stub!(:current_user).and_return(stub_model(User, id: 50))
    view.stub!(:menu_item)
    view.stub!(:mxit_request?).and_return(true)
  end

  it "must show the attempts left" do
    render
    rendered.should have_content("5")
    rendered.should have_content("_ _ t _ _")
  end

  it "must have a games index link on menu" do
    view.should_receive(:menu_item).with(anything,games_path,id: 'games_index')
    render
  end

  it "must have a letter link for each letter" do
    render
    ("a".."z").each do |letter|
      rendered.should have_link(letter, href: play_letter_game_path(@game,letter))
    end
  end

  it "wont letter links that are already chosen" do
    @game.stub!(:choices).and_return("cz")
    render
    rendered.should_not have_link('c', href: play_letter_game_path(@game,'c'))
    rendered.should_not have_link('z', href: play_letter_game_path(@game,'c'))
  end

  it "wont show the letters if game is done" do
    @game.stub(:done?).and_return(true)
    render
    ("a".."z").each do |letter|
      rendered.should_not have_link(letter, href: play_letter_game_path(@game,letter))
    end
  end

  it "must have link to the definition of the word when the game is done on menu" do
    @game.stub(:hangman_text).and_return("define")
    @game.stub(:done?).and_return(true)
    view.should_receive(:menu_item).with(anything,define_word_path(word: 'define'),id: 'define_word')
    render
  end

  it "must have new game link if done on menu" do
    @game.stub(:done?).and_return(true)
    view.should_receive(:menu_item).with(anything,new_game_path,id: 'new_game')
    render
  end

  it "wont have new game link if not done on menu" do
    @game.stub(:done?).and_return(false)
    view.should_not_receive(:menu_item).with(anything,new_game_path,id: 'new_game')
    render
  end

  it "must have a view rank link if done" do
    @game.stub(:done?).and_return(true)
    view.should_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

  it "wont have a view rank link if done" do
    @game.stub(:done?).and_return(false)
    view.should_not_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

  it "must have correct text if you win" do
    @game.stub(:is_won?).and_return(true)
    render
    rendered.should have_content("You win")
  end

  it "must have correct text if you lose" do
    @game.stub(:is_lost?).and_return(true)
    render
    rendered.should have_content("You lose")
  end

  it "must have a link to reveal the clue on menu" do
    Dictionary.should_receive(:clue).with(@game.word).and_return("Cluedo")
    @game.stub(:clue_revealed?).and_return(false)
    view.should_receive(:menu_item).with(anything,play_letter_game_path(@game,'show_clue'),id: 'show_clue')
    render
  end

  it "must show the clue if it has been revealed" do
    Dictionary.should_receive(:clue).with(@game.word).and_return("Cluedo")
    @game.stub(:clue_revealed?).and_return(true)
    view.should_not_receive(:menu_item).with(anything,play_letter_game_path(@game,'show_clue'),id: 'show_clue')
    render
    rendered.should have_content("Cluedo")
  end

end
