require 'spec_helper'
require 'cancan/matchers'

describe Ability do


  before :each do
    @user = create(:user)
    @ability = Ability.new(@user)
  end

  context "Games" do

    it "must be able to view games" do
      @ability.should be_able_to(:read, Game)
    end

    it "wont be able to read other users games" do
      game = create(:game, user: create(:user))
      @ability.should_not be_able_to(:read, game)
    end

    it "must be able to read own users games" do
      game = create(:game, user: @user)
      @ability.should be_able_to(:read, game)
    end

    it "must be able to create games" do
      @ability.should be_able_to(:create, Game)
    end

    it "wont be able to play letters on other users games" do
      game = create(:game, user: create(:user))
      @ability.should_not be_able_to(:play_letter, game)
    end

    it "must be able to play letters on own users games" do
      game = create(:game, user: @user)
      @ability.should be_able_to(:play_letter, game)
    end

  end

  context "Users" do

    it "must be able to read users" do
      @ability.should be_able_to(:read, User)
    end

    it "must be able update self" do
      @ability.should be_able_to(:update, @user)
    end

    it "wont be able update other users" do
      user = create(:user)
      @ability.should_not be_able_to(:update, user)
    end

  end

  context "Winners" do

    it "must be able to read winners" do
      @ability.should be_able_to(:read, Winner)
    end

  end


end