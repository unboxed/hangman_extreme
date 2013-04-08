# encoding: utf-8
require 'spec_helper'

shared_examples "a user geek" do

  it "must allow to look up definition of the word" do
    body = [{'text' => "today is tomorrow"}].to_json
    stub_request(:get, "http://api.wordnik.com/v4/word.json/today/definitions").
      to_return(:status => 200, :body => body, :headers => {})
    create(:won_game, word: "today", user: @current_user)
    visit '/'
    click_link 'show'
    click_link 'define_word'
    page.should have_content("Defining: today")
    page.should have_content("today is tomorrow")
    page.should have_link('new_game')
  end

end

describe 'users', :redis => true do

  context "as mxit user", :shinka_vcr => true do

    before :each do
      @current_user = create(:user, uid: 'm2604100', provider: 'mxit')
      add_headers('X_MXIT_USERID_R' => 'm2604100')
      set_mxit_headers # set mxit user
    end

    it_behaves_like "a user geek"

  end

  context "as mobile user", :smaato_vcr => true do

    before :each do
      @current_user = create(:user, uid: '1234567', provider: 'facebook', mobile_number: '0821234567', real_name: 'Grant Speelman')
    end

    it_behaves_like "a user geek"

  end

end