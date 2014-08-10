# == Schema Information
#
# Table name: games
#
#  id                      :integer          not null, primary key
#  word                    :string(255)
#  choices                 :text
#  user_id                 :integer
#  created_at              :datetime
#  updated_at              :datetime
#  completed               :boolean          default(FALSE)
#  score                   :integer
#  clue_revealed           :boolean          default(FALSE), not null
#  completed_attempts_left :integer
#

require 'spec_helper'
require 'timecop'

describe Game do

  it 'must have a word' do
    Game.new.should have(1).errors_on(:word)
    Game.new(word: 'xx').should have(0).errors_on(:word)
  end

  it 'must have a user' do
    Game.new.should have(1).errors_on(:user_id)
    Game.new(user_id: 123).should have(0).errors_on(:user_id)
  end

  it 'must generate a word' do
    Dictionary.should_receive(:random_value).and_return('wood')
    game = Game.new
    game.select_random_word
    game.word.should be == 'wood'
  end

  context 'add_choice' do

    before :each do
      @game = Game.new
      @game.stub(:attempts_left).and_return(1)
    end

    it 'must allow to add choices if there are still attempts left' do
      @game.should_receive(:attempts_left).and_return(1)
      @game.add_choice('a')
      @game.choices.should include('a')
    end

    it 'wont allow to add choices if there not attempts left' do
      @game.should_receive(:attempts_left).and_return(0)
      @game.add_choice('a')
      @game.choices.should_not include('a')
    end

    it 'wont allow to add choices if more than a letter' do
      @game.add_choice('ab')
      @game.choices.should_not include('a')
      @game.choices.should_not include('b')
    end

    it 'must downcase letters' do
      @game.add_choice('C')
      @game.choices.should include('c')
    end

    it 'must be able to add all letters' do
      ('a'..'z').each do |letter|
        @game.add_choice(letter)
        @game.choices.should include(letter)
      end
      ('1'..'9').each do |number|
        @game.add_choice(number)
        @game.choices.should_not include(number)
      end
    end

  end

  context 'attempts_left' do

    it 'must return the correct amount for no attempts' do
      game = Game.new(word: 'testing')
      game.attempts_left.should be == Game::ATTEMPTS
    end

    it 'must return the correct amount for attempts' do
      game = Game.new(word: 'testing', choices: 'a')
      game.attempts_left.should be == Game::ATTEMPTS - 1
      game = Game.new(word: 'testing', choices: 'ab')
      game.attempts_left.should be == Game::ATTEMPTS - 2
      game = Game.new(word: 'testing', choices: 'testin')
      game.attempts_left.should be == Game::ATTEMPTS
      game = Game.new(word: 'testing', choices: 'atestinb')
      game.attempts_left.should be == Game::ATTEMPTS - 2
    end

  end

  context 'correct_choices' do

    it 'must return the correct amount for attempts' do
      game = Game.new(word: 'testing', choices: 'a')
      game.should have(0).correct_choices
      game = Game.new(word: 'testing', choices: 'at')
      game.should have(1).correct_choices
      game = Game.new(word: 'testing', choices: 'test')
      game.should have(3).correct_choices
      game = Game.new(word: 'testing', choices: 'atestinb')
      game.should have(5).correct_choices
    end

  end

  context 'hangman_text' do

    it 'must return the correct hangman text' do
      game = Game.new(word: 'hangman', choices: 'angmh')
      game.hangman_text.should be == 'hangman'
      game = Game.new(word: 'hangman', choices: 'b')
      game.hangman_text.should be == '_______'
      game = Game.new(word: 'hangman', choices: 'a')
      game.hangman_text.should be == '_a___a_'
      game = Game.new(word: 'hangman', choices: 'ahca')
      game.hangman_text.should be == 'ha___a_'
    end

    it 'must return the full word if game done' do
      game = Game.new(word: 'hangman', choices: 'a')
      game.should_receive(:done?).and_return(true)
      game.hangman_text.should be == 'hangman'
    end

  end

  context 'done?' do

    it 'must be done if no more attempts left' do
      game = Game.new
      game.should_receive(:attempts_left).and_return(0)
      game.should be_done
    end

    it 'must be done if all letters chosen' do
      game = Game.new(word: 'hangman', choices: 'angmh')
      game.should be_done
    end

  end

  context 'is_won?' do

    it 'must be done if all letters chosen' do
      game = Game.new(word: 'hangman', choices: 'angmh')
      game.should be_is_won
    end

  end

  context 'is_lost?' do

    it 'must be lost if no more attempts left' do
      game = Game.new
      game.should_receive(:attempts_left).and_return(0)
      game.should be_is_lost
    end

  end

  context 'when is_done' do

    context 'is true' do

      before :each do
        @game = stub_model(Game, done?: true, :attempts_left => 5)
        @game.save
      end

      it 'must set completed' do
        @game.should be_completed
      end

      it 'must set completed_attempts_left' do
        @game.completed_attempts_left.should be == 5
      end

    end

    context 'is false' do

      before :each do
        @game = stub_model(Game, done?: false, :attempts_left => 5)
        @game.save
      end

      it 'wont set completed' do
        @game.should_not be_completed
      end

      it 'wont set completed_attempts_left' do
        @game.completed_attempts_left.should be_nil
      end

    end

  end

  context 'time_score' do

    it 'must set correct time' do
      time = 10.minutes.ago

      game = stub_model(Game, created_at: time)
      Timecop.freeze(time + 9.seconds) do
        game.time_score.should be == 10
      end
      Timecop.freeze(time + 19.seconds) do
        game.time_score.should be == 9
      end
      Timecop.freeze(time + 79.seconds) do
        game.time_score.should be == 3
      end
      Timecop.freeze(time + 100.seconds) do
        game.time_score.should be == 0
      end
    end

  end

  context 'set_score' do

    before :each do
      @game = stub_model(Game, done?: true)
    end

    it 'wont set score if not done?' do
      @game.stub(:done?).and_return(false)
      @game.save
      @game.score.should be_nil
    end

    context 'no clue revealed' do
      it 'must set score to correct choices + attempts left + time_score' do
        @game.stub(:attempts_left).and_return(2)
        @game.stub(:correct_choices).and_return(['a','b'])
        @game.stub(:time_score).and_return(2)
        @game.clue_revealed = false
        @game.save
        @game.score.should be == 12
      end
    end

    context 'clue revealed' do
      it 'must set score to correct choices + attempts left + time_score' do
        @game.stub(:attempts_left).and_return(2)
        @game.stub(:correct_choices).and_return(['a','b'])
        @game.stub(:time_score).and_return(2)
        @game.clue_revealed = true
        @game.save
        @game.score.should be == 6
      end
    end
  end
end

