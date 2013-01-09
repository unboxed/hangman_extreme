# encoding: utf-8
require 'spec_helper'

describe 'words' do

  before :each do
    @current_user = create(:user, uid: 'm2604101', provider: 'mxit')
    add_headers('X_MXIT_USERID_R' => 'm2604101')
    stub_shinka_request # stub shinka request
    stub_google_tracking # stub google tracking
  end

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